#!/usr/bin/perl

use strict;
use warnings;
use Encode;
use utf8;

my @args = @ARGV;

# 出力先が標準出力以外の場合にもバッファリングを無効にする
$| = 1;
print(encode('utf8',"-----begin------バックグラウンド処理を開始します!---------\n"));
print(encode('utf8',"入力された文字: "));
foreach my $arg(@args){
	print($arg);
	print("\n");
}
foreach my $loop(1 .. 10){
	print(encode('utf-8',"$loop 回目のループ\n"));
	sleep 1; # 1秒まつ
}
print(encode('utf8',"-----end--------バックグラウンド処理を終了します!---------\n"));

