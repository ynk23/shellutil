#!/usr/bin/env perl

use strict ;
use utf8 ;
use CGI ;
use JSON::PP ;
use Time::Local;
use Data::Dumper;

require "./CMN.cgi";

my @jobs = ("aaa","bbb");
my $since_timestamp = 1501506000; # 2017/7/31 22:00 ~

foreach my $job (@jobs){
	my $builds = get_builds($job);
	foreach my $build (@{$builds->{"builds"}}){
		if($build->{"timestamp"} gt $since_timestamp ){
			print $job . "," . $build->{"description"} . ",";
			print_timestamp($build->{"timestamp"}, $build->{"duration"});
			print "\n";
		}
	}
}

sub timestamp2date {
	my $timestamp = shift;
	my ($sec, $min, $hour, $day, $mon, $year) = localtime($timestamp);
	return sprintf('%04d/%02d/%02d %02d:%02d:%02d', $year + 1900, $mon + 1, $day, $hour, $min, $sec);
}

# Jenkins job の開始時間・終了時間を出力
sub print_timestamp {
	my $start_timestamp = shift;
	my $duration = shift;
	my $fin_timestamp = $start_timestamp + $duration;
	print timestamp2date($start_timestamp/1000) . "," . timestamp2date($fin_timestamp/1000); # Jenkins uses milliseconds for the unit
}

# jenkins job のビルド情報 を取得
sub get_builds {
	my $jobname = shift ;
	my $url = "http://" . $CMN::JENKINS_HOST . ":" . $CMN::JENKINS_PORT . "/job/" . $jobname . "/api/json?tree=builds[description,timestamp,duration,url]" ;

	my $res = get( $url ) ;

	if ( $res->code ne "200" ) {
		print "[error] jenkins not found: " . $url . "\n";
		return ;
	}

	my $res_json = decode_json( $res->content ) ;
	return $res_json;
}


# getメソッド
sub get {
	my $url = shift ;
	my $req = HTTP::Request->new('GET',$url) ;
	$req->authorization_basic( $CMN::JENKINS_USER , $CMN::JENKINS_TOKEN ) ;
	my $ua = LWP::UserAgent->new() ;
	my $res = $ua->request( $req ) ;
	return $res ;
}
