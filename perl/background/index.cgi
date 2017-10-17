#!/usr/bin/perl

use strict;
use warnings;
use Jcode;

print "Content-type: text/html; charset= UTF-8\n\n";
my $html = << 'ENDHTML';
<html>
<head>
<title> ajax-sample </title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" /> 
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
</head>
<body>
<p>重い処理をバックグラウンドで実行して、ajaxでそのコンソールログを表示する
<div class='ajax progress'></div>
<div id="jquery-sample">
<!-- ajaxで通信させるため、formのsubmitでpage遷移させないようにする -->
<form class="js-form" action="controller.cgi" method="POST" onsubmit="return false">
  <input type="text" name="INPUTVALUE">
  <input type="hidden" name="ENDPOINT" value="execute">
  <input type="submit" value="submit">
</form>
</div>
<h3>Ajax status</h3>
<div class='ajax status'></div>

<h3>実行ログ表示</h3>
<div>
<textarea class='console txt' rows="20" cols="80"></textarea>
</div>

<!-- end of body. これより下はjavascript -->

<script type="text/javascript">
<!--
/* 
classを設定する
*/
// Ajaxクラス(static)
class Ajax{
	static setup(){
		this.setDefault();
		this.setHandler();
	}
	static setDefault(){
		// ajaxの共通設定
		$.ajaxSetup({
			type    : 'POST',
			timeout : 30000,
			headers: {
				'pragma'           : 'no-cache',
				'Cache-Control'    : 'no-cache',
				'If-Modified-Since': 'Thu, 01 Jun 1970 00:00:00 GMT'
			}
		})
	}
	static setHandler(){
		// ajaxのグローバルイベントハンドラを設定する
		$(document).ajaxSend(function(event, jqXHR, ajaxOptions) {
			// ローディングの表示
			console.log('ajax通信中です');
		}).ajaxComplete(function(event, jqXHR, ajaxOptions) {
			// ローディングの非表示
			console.log('ajax通信終了しました');
		}).ajaxError(function (event, jqXHR, settings, exception) {
			// stackを出力
			if (exception.stack) {
				console.log(exception.stack);
			}else {
				console.log(exception.message, exception);
			}
		})
	}
}

// モニタリングクラス
class Monitor{
	constructor(url, traceData){
		this.url       = url;
		this.traceData = traceData;
		this.timer     = null;
		this.interval  = 1000; // in msec
	}
	set url(url){
		this._url = url;
	}
	set traceData(traceData){
		this._traceData = traceData;
	}
	set timer(timer){
		this._timer = timer;
	}
	get url(){
		return this._url;
	}
	get traceData(){
		return this._traceData;
	}
	get timer(){
		return this._timer;
	}
	fetch(){
		if(!this.timer){
			console.log('timer変数が設定されていません');
			return null;
		}
		$.ajax({
			type     : 'POST',
			url      : this.url,
			dataType : 'json',
			data     : this.traceData
		}).done(function(data, textStatus, jqXHR) {
			// 成功時
			switch(jqXHR.status){
				case 200:
					if(data.STATUS === 'done'){
						$('.ajax.status').html('<p>status: '+jqXHR.status+'(完了)');
						$('.console.txt').val(data.LOG);
						this.stop(); // bindしないと参照不可
					}
					break;
				case 202:
					if(data.STATUS === 'progress'){
						$('.ajax.status').html('<p>status: '+jqXHR.status+'(実行中)');
						$('.console.txt').val(data.LOG);
					}
					break;
				default:
					console.log(jqXHR.status+', 続行します');
					break;
			}
		}.bind(this)).fail(function(jqXHR, textStatus, errorThrown) {
			// 失敗時
			console.log('errorが発生したので終了します');
			this.stop(); // bindしないと参照不可
		}.bind(this));
	}
	start(){
		this.timer = setInterval(this.fetch.bind(this), this.interval); // bindしないとcallback内でthis参照できない
	}
	stop(){
		console.log('繰り返しを終了します');
		clearInterval(this.timer);
	}
}

// 

-->
</script>

<script type="text/javascript">
<!--
/* 
index.js
  - indexのページ内のjavascript
*/
// htmlが読み込まれたときに実行される
$(document).ready(function() {
	// Ajaxクラスをロードする
	Ajax.setup();
	
	// js-formがsubmitされたときcontroller.cgiを実行する
	// ここはajaxでなくても良い
	$('.js-form').on('submit', function(e) {
		e.preventDefault();
		$.ajax({
			url        : $(this).attr('action'),
			type       : $(this).attr('method'),
			dataType   : 'json',
			data       : $(this).serialize()
		}).done(function(data, textStatus, jqXHR) {
			// 成功時
			switch(jqXHR.status){
				case 202:
					$('.ajax.status').html('<p>status: '+jqXHR.status+'(実行中)');
					// コンソールのモニタリング開始
					var traceData = {
						'ENDPOINT'  : 'monitor',
						'SESSIONID' : data.SESSIONID
					}
					var monitor = new Monitor('controller.cgi', traceData);
					monitor.start();
					break;
			}
		}).fail(function(jqXHR, textStatus, errorThrown) {
			// 失敗時
			$('.ajax.status').html('<p>status: '+jqXHR.status+'(エラー終了)');
		});
	});
});

-->
</script>
</body>
</html>
ENDHTML

Jcode::convert($html, 'utf8');
print $html;