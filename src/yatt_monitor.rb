#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#
# yatt (proxy) score server version 2
# programmed by hkim@melt.kyutech.ac.jp
# Copyright (C)2002-2012, Hiroshi Kimura.
#
# VERSION: 0.36
#
# update 2012-04-02, icome connection.
# 2012-04-22, rename yatt_server as yatt_monitor.
#

require 'drb'
require 'sequel'

YATT_VERSION = '0.36'
DATE = '2015-04-11'
REQ_RUBY = "1.9.3"
raise "require ruby >= " + REQ_RUBY if (RUBY_VERSION <=> REQ_RUBY) < 0

def debug(s)
  puts s if $debug
end

def usage
  print <<EOF
USAGE
  #{0} [OPTION]...

OPTIONS(default value)

  --server name, --hostname name, --fqdn name
        use name as yatt score server hostname(localhost).

  --port num
        use num/tcp as yatt score server port(23002).

  --log file
        log yatt/yatt_server communication into file.
        file must be gives as an absolute path(../log/yyyy-mm-dd.log).

  --debug
        debug mode.

EOF
  exit 1
end

class Monitor
  attr_reader :score

  # FIXME: sqlite3 => mysql
  def initialize(ds, logfile)
    @score   = Hash.new(0)
    @ds = ds
    @logfile = logfile
  end

  def clear
    @score.clear
  end

  # CHANGED: return array (was string).
  def best(n)
    @score.sort{|a,b| b[1][0]<=>a[1][0]}[0..n-1]
  end

  def all
    best(@score.length)
  end

  # changed: 2012-04-21, yatt から最高点以外のデータも送られてくる。
  # その変更に対応すること。
  def put(name, score, time)
    debug ("#{__method__}: #{name}, #{score}, #{time}")
    File.open(@logfile,"a") do |fp|
      fp.puts "#{time} #{name} #{score}"
    end
    @ds.insert(:uid => name,
               :score => score,
               :updated_at => Time.now.strftime("%Y-%m-%d %H:%M:%S"))
    if score > @score[name][0]
      @score[name] = [score, time]
    end
  end

  def del(name)
    @score.delete(name)
  end

  # is not called from  anywhere in this file.
  # from outside?
  def load(fname)
    @score.clear
    File.foreach(fname) do |line|
      who, score, time = line.chomp.split(/\s+/)
      @score[who] = [score.to_i, time]
    end
  end

  def rank(name)
    pt     = @score[name][0]
    length = 0
    rank   = 1
    @score.each_value do |val|
      length += 1
      rank += 1 if val[0]>pt
    end
    if rank == 1
      "You are the champ now."
    else
      "#{name}: #{pt} (#{rank}/#{length})"
    end
  end

  # CHANGED: return array
  # 通常の get は DB を引かず、Hash から返す。
  def get(num)
    debug("#{__method__}: #{num}")
    self.best(num)
  end

  # get_myclass はハッシュから。
  # id の前から4文字マッチを取る。
  def get_myclass(num,me)
    pat = %r{#{me[0,4]}}
    ret = Hash.new
    @ds.each do |r|
      uid = r[:uid]
      if uid =~ pat and (ret[uid].nil? or ret[uid][0]<r[:score])
        ret[uid] = [r[:score], r[:updated_at].strftime("%m/%d %H:%M")]
      end
    end
    ret.to_a.sort{|a,b| b[1][0] <=> a[1][0]}
  end

  # get_global のみ、データベースアクセスする。
  # 2012-05-09, c-2g で詰まった。原因は sqlite3 か、drb か?
  def get_global(num)
    ret = Hash.new
    @ds.each do |r|
      uid = r[:uid]
      if ret[uid].nil? or ret[uid][0]<r[:score]
        ret[uid] = [r[:score], r[:updated_at].strftime("%m/%d %H:%M")]
      end
    end
    ret.to_a.sort{|a,b| b[1][0] <=> a[1][0]}
  end

  def remove(me)
    self.del(me)
  end

  def my_rank(me)
    self.rank(me)
  end

  def ping
    "ok"
  end

end

#
# main
#

MONITOR = "yatt.melt.kyutech.ac.jp"
LOG  = "/opt/yatt/log/yatt.log"
PORT = 23002
BEST = 30
DB = "mariadb.melt.kyutech.ac.jp"

hostname = MONITOR
port     = PORT
logfile  = LOG

$sqlite = false
while (arg = ARGV.shift)
  case arg
  when /\A--(fqdn)|(hostname)|(server)\Z/
    hostname = ARGV.shift
  when /\A--port\Z/
    port = ARGV.shift.to_i
  when /\A--log\Z/
    logfile = ARGV.shift
  when /\A--sqlite/
    $sqite = true
  when /\A--debug/
    $debug = true
  else
    usage
  end
end

# 2015-04-02, db.melt => mariadb.melt
if $sqlite
  ds = Sequel.sqlite("../db/yatt.db")[:yatt]
else
  ds = Sequel.connect("mysql2://yatt:yyy@#{DB}/yatt")[:yatt]
end

debug [RUBY_VERSION, YATT_VERSION, hostname, port].join(", ")

begin
  monitor = Monitor.new(ds, logfile)
  uri = "druby://#{hostname}:#{port}"
  puts uri if $debug
  DRb.start_service(uri, monitor)
  DRb.thread.join

rescue => e
  puts "#{e.class}:#{e.message}"
end

