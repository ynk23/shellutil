#!/usr/bin/env perl

use strict ;
use utf8 ;
use CGI ;
use JSON::PP ;
use FindBin;
use File::Basename;
use Getopt::Long 'GetOptions';
use Data::Dumper;
use DateTime::Format::HTTP;

# スクリプト名を取得
my $script_name = basename($0, '');

# 使い方を表示
sub print_usage{
        print "Usage: $script_name --since=<date> --until=<date>. (date e.g. YYYY-MM-DD in localtime)\n";
}

# global 変数
my $since = '';
my $until = '';

# optionを取得
GetOptions(
	'since=s' => \$since,
	'until=s' => \$until
) ;

# validation check
if( $since eq "" &&  $until eq "" ){
	print "[error] --since=<date_utc> or --until=<date_utc> is required.\n";
	print_usage();
	exit 0; 
}
if($since ne ""){
	until( $since =~ /^([0-9]{4})-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$/ ){
		# 2017-12-01 のようなフォーマットにマッチしなければエラー
		print "[error] --since=<date_utc> is not YYYY-MM-DD.\n";
		print_usage();
		exit 0; 
	}
}
if($until ne ""){
	until( $until =~ /^([0-9]{4})-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$/ ){
		# 2017-12-01 のようなフォーマットにマッチしなければエラー
		print "[error] --since=<date_utc> is not YYYY-MM-DD.\n";
		print_usage();
		exit 0; 
	}
}

# $sinceと$untilを検索できるように正規化
my $datetime_since = '';
my $datetime_until = '';
if($since ne ""){
	$datetime_since = get_localtime($since);
}
if($until ne ""){
	$datetime_until = get_localtime($until);
}

my $issues = get_issue('closed');
for my $issue(@{$issues}){
	my $url = $issue->{'url'};
	my $closed_at = $issue->{'closed_at'};
	my $datetime = get_localtime($closed_at);
	if($datetime_since ne "" && $datetime_until ne ""){
		# 始まりと終わりが指定されている場合
		if($datetime < $datetime_since || $datetime > $datetime_until->add(days=>1)){
			# 範囲外のissueはスキップ
			next;
		}
	}elsif($datetime_since ne ""){
		# 始まりだけ指定されている場合
		if($datetime < $datetime_since){
			# 範囲外のissueはスキップ
			next;
		}
	}elsif($datetime_until ne ""){
		# 終わりだけ指定されている場合
		if($datetime > $datetime_until->add(days=>1)){
			# 範囲外のissueはスキップ
			next;
		}
	}else{
		# 開始も終わりも指定されていない場合は不正なのでループを抜ける
		last;
	}
	print "$datetime,$url\n";
}

# localのタイムゾーンのdatetimeを返す関数
sub get_localtime{
	my $time_str = shift;
	until(defined($time_str)){
		return 0; # false
	}
	my $datetime = DateTime::Format::HTTP->parse_datetime($time_str);
	# i.e. 2017-10-02          -> 2017-10-02T00:00:00 のように補完される
	# i.e. 2017-10-02T23:43:12 -> 2017-10-02T23:43:12 はそのまま
	my $datetime_local = $datetime->set_time_zone('Asia/Tokyo');
	return $datetime_local;
}
