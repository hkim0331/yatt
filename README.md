# Yatt (Yet Another Typing Tutor)

## DON'T FORGET

mysql(mariadb) の grant all privileges ...
さもないと Seqeul がどうののエラーでトンチンカンに時間を潰すだろう。

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

---
hkimura.

