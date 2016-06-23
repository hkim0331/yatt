この内容は README じゃねーな。

## depends


## 2016-03-31

* OSX：rbenv でインストールした ruby 2.2.3 + ActiveTcl8.6 で ruby yatt.rb OK。

* 2.2.4 だと NG。2.3.x も NG。

* 情報センターの /edu/bin/ruby は hkimura build の 2.1.0.

## TODO

* 誤って修飾キー押してもスタートしないように。

* last score を表示するのはどうか。

* windows インストーラ、あるいはインストールの説明

* 自宅練習のための仮想アカウント

## 2015-04-02

  データベースサーバ変更。db.melt => mariadb.melt

## 2014-04-25

  isc で ruby-2.1.1/tk8.5 OK. /edu/bin/ruby で。

## 2014-04-02

  yatt_monitor はデータの授業利用のため、web.melt でサービスしよう。

## 2012-05-09 contest/global 選択時、c-2g で糞詰まり。sqlite3 問題か。

  mysql に行ってみるか。
  その前に、global/reload メニューに sleep(1) をはさんでみる。

## FIXME: vm3:/etc/rc.local から yatt_server が起動しない。2012-04-16.

  => sequel を見つけていない。/usr/local/bin/ruby を使ってもダメ。
     /etc/rc.local の制限があるのか? ライブラリサーチパス?

## ruby 1.9 で動くように。

  => 2012-03-*## done.

## osx で /opt/local/bin/ruby を使うとエラー、

  /opt/local/lib/ruby/1.8/drb/drb.rb:852:in `initialize': getaddrinfo: nodename nor servname provided, or not known (SocketError)
  /usr/bin/ruby でもエラー、
  yatt.rb:192:in `initialize': /usr/local/lib/yatt/yatt.doc does not exist  (RuntimeError)
  つまり、チェックアウト直後(r948)は全く動かない。
  速攻で動かせそうなのは /usr/bin/ruby の方。
  => ruby 1.9 で動かす。

## isc では courier 14pt で動かすこと。2009-04-13

  => done.
