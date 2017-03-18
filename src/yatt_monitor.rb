#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#
# yatt (proxy) score server version 2
# programmed by hkim@melt.kyutech.ac.jp
# Copyright (C) 2002-2017, Hiroshi Kimura.
#
# update 2012-04-02, icome connection.
# 2012-04-22, rename yatt_server as yatt_monitor.
#

require 'drb'
require 'sequel'

YATT_VERSION = '0.60'
DATE = '2017-03-19'

DRUBY = "druby://150.69.90.82:23002"
DB    = "150.69.90.82"
LOG   = "/srv/yatt/log/yatt.log"
BEST  = 30

def debug(s)
  STDERR.puts "debug: " + s if $debug
end

def usage
  print <<EOF
USAGE
  #{0} [OPTION]...

OPTIONS(default value)

  --druby
        use uri for remote druby object(#{DRUBY}).

  --log file
        log yatt/yatt_server communication into file.
        file must be gives as an absolute path(../log/yyyy-mm-dd.log).

  --debug
        debug mode.

EOF
  exit 1
end

# @score は monitor の立ち上がり時にリセットされる。
# これが weekly の実態だ。
# global（つまりリモートのデータベース）に記録されるのは別のタイミング。
class Monitor
  attr_reader :score

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

  # BUG 2015-04-23
  def status(name)
    pt     = @score[name][0]
    length = 0
    rank   = 1
    @score.each_value do |val|
      length += 1
      rank += 1 if val[0]>pt
    end
    ret = "#{pt} pt, ##{rank} of #{length} players."
    if rank == 1
      ret << "\nYou are the weekly champ."
    end
    ret
  end

  # CHANGED: return array
  # 通常の get は DB を引かず、Hash から返す。
  def get(num)
    self.best(num)
  end

  # get_myclass はハッシュから。
  # id の前から4文字マッチを取る。
  def get_myclass(num,sid)
    pat = %r{#{sid[0,4]}}
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
      if ret[uid].nil? or ret[uid][0] < r[:score]
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

druby   = DRUBY
logfile = LOG

$sqlite = false
while (arg = ARGV.shift)
  case arg
  when /\A--druby\Z/
    druby = ARGV.shift
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

begin
  DRb.start_service(druby, Monitor.new(ds, logfile))
  puts "druby: #{DRb.uri}"
  DRb.thread.join

rescue => e
  puts "#{e.class}:#{e.message}"
end

