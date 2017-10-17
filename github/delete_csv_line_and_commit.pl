#!/usr/bin/env perl

use strict;
use File::Basename;
use File::Path;
use Text::CSV_XS;
use Getopt::Long 'GetOptions';
use LWP::UserAgent ;
use IO::Socket::SSL ;
use JSON::PP;
use FindBin;
use Data::Dumper;
binmode(STDOUT, ":utf8");

# スクリプト名を取得
my $script_name = basename($0, '');

# 使い方を表示
sub print_usage{
        print "Usage: $script_name --org= <org_name> delete_key1 ...\n";
}

# current directory を取得
my $dir = $FindBin::Bin;

# global 変数
my $org = "";
my $force = "";
my @deletes = ();
my @repositories = ();
my $GHE_URL = "https://enterprise.github.com";
my $GHE_TOKEN = "";
my $API_BASE = $GHE_URL . "/api/v3/";
my $RAW_BASE = $GHE_URL . "/raw/";
my $work = $dir . "/work/";

# optionを取得
GetOptions(
	'org=s' => \$org,
	'force' => \$force
) ;

# 引数を取得
@deletes = @ARGV;

# validation check
if( $org eq "" ){
        print "[error] --org <org_name> is required.\n";
        print_usage();
        exit 0; 
}
if( !@deletes ){
        print "delete_keys is required.\n";
        print_usage();
        exit 0;
}

# csvパース用のインスタンス
my $csv = Text::CSV_XS->new({
  'quote_char'   => '"',
  'escape_char'  => '"',
  'always_quote' => 1,
  'binary'       => 1,
});

# 作業ディレクトリを作成
if (!-d $work){
	mkdir $work;
}

# リポジトリを取得
if(get_repositories()){
	for my $repository(@repositories){
		my %repo_data = (
			'name'     => $repository,
			'url'      => $GHE_URL."/".$org."/".$repository.".git",
			'dir'      => $repository.".git",
			'dir_path' => $work.$repository.".git"
		);
		# 参照変数に格納
		my $repo = \%repo_data;
		# settingsがあるか確認
		my $url = $RAW_BASE . $org . "/" . $repo->{'name'} . "/master/docs/settings";
		my $res = get( $url ) ;
		if ( $res->code ne "200" ) {
			print "[info] no settings : " . $repo->{'name'} . "\n";
			next;
		}
		# git repository を取得する
		chdir $work or die "Cannot change directory $work: $!";
		if(-d $repo->{'dir_path'} && !-d $repo->{'dir_path'}."/.git"){
			# .gitがなければリポジトリディレクトリを削除
			print "[info] rmtree ".$repo->{'dir_path'}."\n";
			rmtree($repo->{'dir_path'});
		}
		if(-d $repo->{'dir_path'}){
			# remote url が異なればリポジトリディレクトリを削除
			chdir $repo->{'dir_path'} or die "Cannot change directory $repo->{'dir_path'}: $!";
			my $remote_url = `git config --get remote.origin.url 2>\&1`;
			chdir $work or die "Cannot change directory $work: $!";
			# 判定するために改行を削除
			$remote_url =~ s/[\r\n]+//g;
			if ($remote_url ne $repo->{'url'}){
				print "[info] rmtree ".$repo->{'dir_path'}."\n";
				rmtree($repo->{'dir_path'});
			}
		}
		# すでにディレクトリがある場合はfetchする
		if(-d $repo->{'dir_path'}){
			print "[info] chdir " . $repo->{'dir_path'} . "\n";
			chdir $repo->{'dir_path'} or die "Cannot change directory $repo->{'dir_path'}: $!";
			# checkoutする
			mygit("checkout master");
			# fetchする
			mygit("fetch origin master");
			# resetする
			mygit("reset --hard origin/master");
		}else{
			# ディレクトリがない場合はcloneする
			mygit("clone -b master " . $repo->{'url'} . " " . $repo->{'dir'});
			chdir $repo->{'dir_path'} or die "Cannot change directory $repo->{'dir_path'}: $!";
		}
		# この時点で$repo_dirの中にいる
		# 不要な変更ファイルを削除する
		mygit("clean -fdx");
		mygit("checkout .");
		if($force){
			# delete_key の行を削除する
			if(-f "docs/settings"){
				if(delete_line("docs/settings")){
					print "[info] >>> ".$repo->{'name'}." success\n";
				}else{
					print "[error] >>> ".$repo->{'name'}."failed\n";
					exit 1;
				}
			}
			# commitする
			mygit("add docs/settings");
			if(has_change("docs/settings")){
				mygit("commit -m 'Update'");
				# pushする
				mygit("push origin master");
			}
		}else{
			print "[info] -------- dry-run -------\n";
			print "[info] ++     do nothing     ++\n";
			print "[info] -------- dry-run -------\n";
		}
	}	
}else{
	print "[error] failed to get repositories : " . $org . "\n";
	exit 1;
}

exit 0;

sub get {
        my $url = shift ;
        my $req = HTTP::Request->new('GET',$url) ;
        $req->header('Authorization' => "token " . $GHE_TOKEN);
        $req->header('Accept' => 'application/vnd.github.mockingbird-preview');
        
        my $ua = LWP::UserAgent->new(
                # 自己署名の証明書対策
                ssl_opts => {
                        verify_hostname => 0 ,
                        SSL_verify_mode => SSL_VERIFY_NONE
                }
        ) ;

        # URLにアクセスし、データを得る
	print "[info] get ".$url."\n";
        my $res = $ua->request( $req ) ;

        return $res ;
}

# orgからリポジトリ名を取得
sub get_repositories{
	for( my $page = 1 ; ; ++$page ) {
		my $url = $API_BASE . "orgs/" . $org . "/repos?page=" . $page ;
		my $res = get($url) ;
		if ( $res->code ne "200" ) {
			print "[error] response code : " . $res->code . "\n" ;
			return 0;
		}
		if ( $res->content eq "[]" ) {
			last ;
		}
		my $json = decode_json( $res->content ) ;
		foreach my $repos ( @{$json} ) {
			push(@repositories,$repos->{"name"});
		}
	}
	return 1;
} 

# gitコマンドのwrapper
# error の場合はそのままexitする
sub mygit{
	my $cmd = shift;
	print "[info] git ".$cmd."\n";
	my $std = `git $cmd 2>\&1`;
	if($? ne "0"){
		print "[error] " . $std . "\n";
		exit 1;
	}
	return 1;
}

# ファイルが変更されたかの判定関数
sub has_change{
	my $file = shift;
	# ファイルがなかったらエラー終了
	if(!-f $file){
		print "[error] not file : ".$file."\n";
		exit 1;
	}
	# git add したので変更したファイルを取得
	# e.g.) M docs/settings
	my $std = `git status --short 2>\&1`;
	if($? ne "0"){
		print "[error] ".$std."\n";
		exit 1;
	}else{
		if($std =~ /[AM]+\s+$file/){
			# $file が変換されたのでtrue
			return 1;
		}else{
			# $file が変換されていないのでfalse
			return 0;
		}
	}
}

# csvファイルから該当行を削除する関数
sub delete_line{
	my $file_in_out = shift;
	# 読み込み書き込み両用でファイルを開く
	open (fp_io,"+<$file_in_out") or die "[error] $!: $file_in_out";
	my @csv_data = ();     # 書き込みデータを保持する配列
	my $line_count = 0;
	# csvファイルを1行ずつ読み込み
	while(<fp_io>) {
		$line_count++;
		my $line = $_;      # パース用
		my $orig_line = $_; # 書き出し用に保持
		# 先頭のコメントマーク###を削除
		if($line =~ /^###".*/){
			$line =~ s/###//;
		}
		# それ以外のコメントはそのまま書き出し
		if($line =~ /^#.*/){
			# そのまま書き出しデータに追加
			push(@csv_data,$orig_line);
			next;
		}
		# コメント行でないものはパースしてkeyに一致したら削除する
		# ### で始まる行もこのロジックを通す
		# コメントを削除しパースできるようにする
		$line =~ s/".*#.*//;
		# 行単位のパース
		my $status = $csv->parse($line);
		if($status != 1){
			# 読み込めなかったらエラー
			print "[error] failed to parse row: ".$line_count." -- ".$file_in_out."\n";
			return 0;
		}
		my @cols_in = $csv->fields();
		my @cols_out;
		  # ---- ---- ---- ---- ----
		  #   0    1    2    3    4
		  # ---- ---- ---- ---- ----
		  # key, val, val, val, val
		  # ------------------------
		  # のcsvを読み込む
		  # keyの値が$delete_keyに完全一致したら行を削除する
		if( has_item(\@deletes,$cols_in[0]) ){
			# 削除
			print "[info] delete: ".$orig_line;
		}else{
			# そのまま書き出し用データに追加
			push(@csv_data,$orig_line);
		}
	}
	# 書き出し処理
	seek(fp_io, 0, 0);                                   # ファイルの先頭に移動
	foreach(@csv_data){print fp_io $_;}                  # 書き出し
	truncate(fp_io, tell(fp_io)) or die "[error] $!" ;  # ファイルサイズを書き込んだサイズにする
	# ファイルをクローズ
	close(fp_io);
	return 1;
}

# 配列の要素に存在するか確認する関数
sub has_item{
        my ($arr, $item) = @_;
        my $arr_length = @$arr;
        foreach my $val (@$arr){
                if ($val eq $item ){
                        return 1; # true
                }
        }
        return 0; # false
}
