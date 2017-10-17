#!/usr/bin/perl
package CMN;

use strict;
use warnings;

use LWP::UserAgent ;
use IO::Socket::SSL ;

# Jenkinsの設定
our $JENKINS_HOST = "xxx" ;
our $JENKINS_PORT = "8080" ;
our $JENKINS_USER = "xxx" ;
our $JENKINS_TOKEN = "xxx" ;


# デバッグ設定
our $DEBUG_FLG = 1;
