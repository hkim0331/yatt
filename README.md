# Yatt (Yet Another Typing Tutor)

## DON'T FORGET

mysql(mariadb) の grant all privileges ...
さもないと Seqeul がどうののエラーでトンチンカンに時間を潰すだろう。

## 2017-05-03

「最近の傾向をみて警告を表示」に手をつける。

* accuracy, history はそれぞれ、errors, records がよかったな。
* ACCURACY_THRES 導入


## 2017-03-15

* mbp2
  ruby(2.4.0) + gem install tk

* tmint, isc
  ruby2.3-tcltk ではエラーで動かない。
  ruby <~ 2.2 + tk8.5

2.2.6 を以下のオプションでインストールすると tmint では動いた。

```sh
$ ./configure --prefix=/opt \
--with-tcltkversion=8.6 \
--with-tcl-lib=/usr/lib/x86_64-linux-gnu \
--with-tk-lib=/usr/lib/x86_64-linux-gnu \
--with-tcl-include=/usr/include/tcl8.6 \
--with-tk-include=/usr/include/tcl8.6 \
--enable-pthread \
--disable-install-doc --disable-install-rdoc
$
```

動かない時のログ。

```sh
$ /opt/bin/ruby yatt.rb
/usr/lib/ruby/2.3.0/tk/itemconfig.rb:115:in `hash_kv': wrong argument type nil (expected Array) (TypeError)
	from /usr/lib/ruby/2.3.0/tk/itemconfig.rb:115:in `itemconfig_hash_kv'
	from /usr/lib/ruby/2.3.0/tk/canvas.rb:722:in `_parse_create_args'
	from /usr/lib/ruby/2.3.0/tk/canvas.rb:735:in `create'
	from /usr/lib/ruby/2.3.0/tk/canvas.rb:758:in `create_self'
	from /usr/lib/ruby/2.3.0/tk/canvas.rb:751:in `initialize'
	from yatt.rb:1129:in `new'
	from yatt.rb:1129:in `plot'
	from yatt.rb:1113:in `initialize'
	from yatt.rb:137:in `new'
	from yatt.rb:137:in `initialize'
	from yatt.rb:1160:in `new'
	from yatt.rb:1160:in `<main>'
$
```

## 2016-03-31

* OSX：rbenv でインストールした ruby 2.2.3 + ActiveTcl8.6 で ruby yatt.rb OK。

* 2.2.4 だと NG。2.3.x も NG。

* 情報センターの /edu/bin/ruby は hkimura build の 2.1.0.

* 2.2.4 や 2.3.0 では Tk が正しく起動しない。

* 情報センターの /edu/bin/ruby は 2.1.0

## TODO

* 誤って修飾キー押してもスタートしないように。

* last score を表示するのはどうか。

* windows インストーラ、あるいはインストールの説明

* last score を表示するのはどうか。
* windows インストーラ、あるいはインストールの説明
* 自宅練習のための仮想アカウント

## DONE

* [2015-04-02] データベースサーバ変更。db.melt => mariadb.melt

* [2014-04-25] isc で ruby-2.1.1/tk8.5 OK. /edu/bin/ruby で。

* [2014-04-02] yatt_monitor はデータの授業利用のため、web.melt でサービスしよう。

* [2012-05-09] contest/global 選択時、c-2g で糞詰まり。sqlite3 問題か。

  mysql に行ってみるか。
  その前に、global/reload メニューに sleep(1) をはさんでみる。

* [2012-04-16] [FIXME] vm3:/etc/rc.local から yatt_server が起動しない。

  => sequel を見つけていない。/usr/local/bin/ruby を使ってもダメ。
     /etc/rc.local の制限があるのか? ライブラリサーチパス?

* [2012-03] ruby 1.9 で動くように。


*  osx で /opt/local/bin/ruby を使うとエラー、

  /opt/local/lib/ruby/1.8/drb/drb.rb:852:in `initialize': getaddrinfo: nodename nor servname provided, or not known (SocketError)
  /usr/bin/ruby でもエラー、
  yatt.rb:192:in `initialize': /usr/local/lib/yatt/yatt.doc does not exist  (RuntimeError)
  つまり、チェックアウト直後(r948)は全く動かない。
  速攻で動かせそうなのは /usr/bin/ruby の方。
  => ruby 1.9 で動かす。

* [2009-04-13] isc では courier 14pt で動かすこと。2009-04-13

## (old) ChangeLog

2012-04-22  Hiroshi Kimura  <hiroshi.kimura.0331@gmail.com>

  * git のログとこの ChangeLog にだぶって記録を残すのはめんどう。
    めんどうだとよくないことが必ず起こる。

2012-04-17  Hiroshi Kimura  <hiroshi.kimura.0331@gmail.com>

	* src/yatt.rb (SpeedMeter#min): TODAYS_SCORE を yatt 起動時に作成。

2012-04-15  Hiroshi Kimura  <hiroshi.kimura.0331@gmail.com>

	* yatt.rb: $MYDEBUGを削除。ついでにメニューも。

	* yatt.rb (Scoreboard#auth): 酷いauthをシンプルに。

	* yatt.rb (Scoreboard#can_not_talk): can_not_talk の文章を日本語に。

	* 古いChangeLogは文字コードのせいか、ふつうに読めない。
	  そいつをChangeLog.oldと名前を変えて、
	  あたらしいChangeLogを開始。

2005-05-19  Hiroshi Kimura  <hkim@nimbus.melt.kyutech.ac.jp>

	* yatt.rb (Trainer::insert): ドキュメントの選び方をちょっと改良。

2004-05-14  Hiroshi Kimura  <hkim@dercy.melt.kyutech.ac.jp>

	* rename yatt2d_probe.rb as yatt2probe.rb

2004-05-10  Hiroshi Kimura  <hkim@dercy.melt.kyutech.ac.jp>

	* yatt2.rb (menu_new): bug fix.

2004-05-08  Hiroshi Kimura  <hkim@dercy.melt.kyutech.ac.jp>

	* yatt2-branch joined.
	osx での動作を確認。
	--myid myid オプション
	認証を authentication(), authenticated に分離
	ランキングボードにランクインの日付を表示
	過去のソースを清算。
	drb-2.0.4 の採用。

2004-05-03  Hiroshi Kimura  <hkim@dercy.melt.kyutech.ac.jp>

	* yatt2-branch start.

2003-10-08  Hiroshi Kimura  <hkim@dercy.melt.kyutech.ac.jp>

	* yatt_score_server.rb (STUDENTS): --db dbfile オプション。
	初期値 STUDENTS を上書きする。
	(db): インタラプト例外を捕獲し、データをダンプする。

	* Makefile: s/yatt/yatt.rb/g
	yatt.rb を学期ごとに yatt でラップして使おう。

2003-02-21  Hiroshi Kimura  <hkim@melt.kyutech.ac.jp>

	* yatt.rb: drb を用いてスコアサーバを全面的に書き直し。これにてバー
	ジョンは 0.8 に。

2002-10-21  Hiroshi Kimura  <hkim@melt.kyutech.ac.jp>

	* デバッグ出力を整理。
	* ttserv, ttbind を yatt_logger, yatt_snort にリネーム。
	* メソッド reset を clear にリネーム。

2002-10-10  Hiroshi KIMURA  <hkim@nimbus>

	* ttserv: ラッパーなしでも認証するように。つまり、認証を甘くしたわ
	けだ。

	* yatt.rb: (happy birth day! aoi-chan) 環境別設定を整理。Windows
	ではまともに動かないだろう。パスのセパレータ等を見直す必要あり。

2002-07-05  Hiroshi Kimura  <hkim@melt.kyutech.ac.jp>

	* yatt.rb (is_alive?): ttserv との接続にタイムアウトを設けた。
	これにより、ttserv と通信できないときに、join_compe や reload を実
	行して yatt が停止してしまうバグを回避。
	ソケット関数を一本化。
	join_compe, sumit メソッドを Scoreboard クラスに移動。

2002-06-12  Hiroshi Kimura  <hkim@melt.kyutech.ac.jp>

	* yatt.rb :情報センターでも compe に参加できるようにする。
	バグ: runnable_before で立ち上がった後、時間が来ても run できる。

2002-06-11  Hiroshi Kimura  <hkim@melt.kyutech.ac.jp>

	* yatt.rb (YATT_VERSION): windows でも動くようになった。
	speed meterの追加。

2002-06-08  Hiroshi KIMURA  <hkim@nimbus>

	* yatt.rb (key_press): 書き直し。これによって、オーバーランした入
	力を次の面に繰り越さなくなった。yatt.rb が落ちることもなくなった。
	また、コードもきっと見やすくなったと思うぞ。

	* BUG : キー入力のオーバーランが多いと yatt.rb が落ちる。これは
	Loose モードで発生しやすい(上の作業で fix)。

	* yatt.rb : bonus(complete, perfect)。メニューのプログラムを変更。
	ブロック内部から外部インスタンス変数を参照しそこなう。(ブロック定
	義時の環境をコピーしている?) あとでもう一度メニューに手を入れる。
	チェックボックス風に。
	(Logger#score) 計算式を新規に。

	* ttbind : functions get/reset/dump/load

	* ttserv : load

2002-06-07  Hiroshi Kimura  <hkim@melt.kyutech.ac.jp>

	* yatt.rb (MyText.sticky): stickyモード --タイプミスの場所をしつこ
	く表示する。
	create class MyPlot
	Trainer.submit 毎回 auth

2002-06-06  Hiroshi Kimura  <hkim@melt.kyutech.ac.jp>

	* yatt.rb (key_press): 	@@epilog を使い、ダイアログをひとつしか表
	示しないように。

	* yatt.rb (join_compe): md5sum によるソースファイル認証。

2002-06-01 Hiroshi Kimura  <hkim@melt.kyutech.ac.jp>
	過去ログ
	* ログ(half done, 06.01)
	統計情報をファイルに記録する。ファイルを読んでグラフ表示する。成績
	と頻度(正解+誤タイプ)。キーごとに成績を表示する。

	* total/todays がまだ未実装。

	* タイムアウト
	途中終了したときとそうでないときとの成績に差をつける。

	* startup ファイルの準備

	* ボードの表示が整列してない(06.01)。

	* ダイアログ、スレッドまわりの動作が不安定(06.01)
	スレッドやめた。やめて TkAfter に変更したら安定した感じ。

	* リアルタイム成績表示プログラム(05.30)
	オンラインでスコアを集計し、表示するプログラムとの連動。
	woody ruby-1.6.7-3 の動作がおかしい。

	* タイマーの処理(half done 05.28)
	現バージョンは有無を言わさず exit する。これをきちんと後始末をする
	ように変える。

	* 細かいプログラムの流れ(05.28)
	現バージョンは、ウィンドウがオープンすると即、タイマーがカウントを
	始める。これをさいしょの keypress イベントからに変える。

	* リトライ(05.28)

	* パラメータ処理(05.25)
	コマンドラインと、初期化ファイルの扱いを一元化する。



---
hkimura.
