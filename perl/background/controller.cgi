#!/usr/bin/perl

use strict;
use warnings;
use CGI;
use CGI::Session;
use JSON;
use Encode;
use Data::Dumper;

=head sub
	このスクリプトで利用するサブルーチン
=cut

sub exfork{
	my ($log, $com, @argv) = @_;
	my $pid = fork;
	return unless defined $pid; # fork失敗
	unless ($pid) { # 子プロセス
		close(STDOUT);
		# 外部スクリプト側で出力先が標準出力でない場合はバッファリングされてしまうので
		# これを無効にしておかないと都度ログが吐き出されない
		# perlでは `$| = 1`としておけばよい
		exec("$com @argv > $log 2>&1");
		exit;
	}
	return $pid;
}

sub setResponseHeader($){
	my $status = shift;
	if($status eq 'success'){
		print "Status: 200 OK\n";
		print "Content-type:text/html\n\n";
		return;
	}elsif($status eq 'accept'){
		print "Status: 202 Accepted\n";
		print "Content-type:text/html\n\n";
		return;
	}elsif($status eq 'failed'){
		print "Status: 500 Internal Server Error\n";
		print "Content-type:text/html\n\n";
		return;
	}else{
		print "Status: 500 Internal Server Error\n";
		print "Content-type:text/html\n\n";
		return;
	}
	return;
}

sub setResponseData($){
	my $responseData = shift;
	# 結果を返す
	print encode_json($responseData);
	return;
}

sub writeFile{
	my ($file, $txt, $mode) = @_;
	my $flag = '>>'; # default: appned
	if($mode eq 'ovewrite'){
		$flag = '>';
	}elsif($mode eq 'append'){
		$flag = '>>';
	}else{
		$flag = '>>';
	}
	open(OUT, $flag, $file) or die "[write]cannot open file '$file' : $!";
	print OUT ($txt);
	close(OUT);
	return;
}

sub loadFile($){
	my $file = shift;
	local $/ = undef;
	my $data;
	open(IN, "<:utf8", $file) or die "[load]cannot open file '$file' : $!";
	$data = <IN>;
	close(IN);
	return $data;
}

sub isAlive($){
	my $pid = shift;
	my $result = kill(0,$pid);
	return $result;
}

=head main
	ここから処理開始
	上のサブルーチンの宣言は外部ファイルに置いたほうがよい
=cut

# CGIのリクエストを受け取って解析する
our $q = new CGI ;

my $endpoint = $q->param('ENDPOINT') || '';

if($endpoint eq 'execute'){
	# リクエストごとにCGIのセッションを作成
	my $session = CGI::Session->new("driver:File", undef, {Directory=>'session'});
	# 有効期限を設定
	$session->expire('+10m');
	# 有効なセッションIDを取得
	my $sid = $session->id();
	# 外部スクリプトに渡す引数をリクエストから取得
	my $inputvalue = $q->param('INPUTVALUE') || '';
	# 外部スクリプトのログファイルとPIDを保存するファイルを指定
	my $subConsolelog = "log/console-$sid.txt";
	# background.plをバックグラウンドで実行
	my $pid = exfork($subConsolelog, './background.pl', $inputvalue);
	# セッションに追跡用のデータ格納
	$session->param("PID", $pid);
	$session->param("TIME", time());
	if(defined($pid)){
		setResponseHeader('accept');
		# jsonデータをresponseのbodyに入れる
		# cookieに入れたほうがよさそう
		my $responseData = {
			"SESSIONID" => $sid,
		};
		setResponseData($responseData);
	}else{
		setResponseHeader('failed');
		$session->delete();
	}
}elsif($endpoint eq 'monitor'){
	# リクエストからセッションIDを取得
	my $sid = $q->param('SESSIONID') || (setResponseHeader('failed') && exit);
	# セッションを読み込み
	my $session = CGI::Session->load("driver:File", $sid, {Directory=>'session'});
	# セッションIDから外部スクリプトのログファイルを指定して読み込み
	my $subConsolelog = "log/console-$sid.txt";
	my $logdata = loadFile($subConsolelog);
	# sessionに登録されているpidがテーブルにあるかを確認して状態に応じたレスポンスデータを作る
	my $responseData = {
		'SESSIONID' => $sid,
		'LOG'       => $logdata,
		'STATUS'    => ''
	};
	if(isAlive($session->param("PID"))){
		# まだ動いている場合
		$responseData->{'STATUS'} = 'progress';
		setResponseHeader('accept');
		setResponseData($responseData);
	}else{
		# すでに終了している場合
		$responseData->{'STATUS'} = 'done';
		setResponseHeader('success');
		setResponseData($responseData);
		# sessionを削除
		$session->delete();
		# ログファイルを削除
		unlink $subConsolelog or warn "Could not rm $subConsolelog: $!";
	}
}else{
	# 他のスクリプトを実行
	setResponseHeader('failed');
}

exit;

