#!/usr/bin/env perl

use strict ;
use utf8 ;
use CGI ;
use JSON::PP ;
use Data::Dumper;

require "./CMN.cgi";

my @jobs = ("aaa","bbb");
my $since_timestamp = 1501506000; # 2017/07/31/220:00:00 ~

foreach my $job (@jobs){
	my $builds = get_builds($job);
	foreach my $build (@{$builds->{"builds"}}){
		if($build->{"timestamp"} gt $since_timestamp ){
			my $console_url = $build->{"url"} . "consoleText";
			my $tag_name = $build->{"description"};
			my $logfile_name = $job . "_" . $tag_name . ".txt";
			print "[info] " . $job . "," . $logfile_name . "," . $console_url . "\n";
			output_console_log($console_url, $logfile_name);
		}
	}
}

# Jenkins job のconsole 出力をファイルに出力
sub output_console_log {
	my $url = shift;
	my $logfile = shift;
	
	my $res = get( $url );
	if ( $res->code ne "200"){
		print "[error] console text not found: " . $url . "\n";
		print Dumper $res;
		return ;
	}
	my $console_log = $res->content ;
	
	open( OUT , ">console/$logfile" ) or die "not open:" . $logfile ;
	print OUT $console_log ;
	close( OUT );
}


# jenkins job のビルド情報 を取得
sub get_builds {
	my $jobname = shift ;
	my $url = "http://" . $CMN::JENKINS_HOST . ":" . $CMN::JENKINS_PORT . "/job/" . $jobname . "/api/json?tree=builds[description,timestamp,url]" ;

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

