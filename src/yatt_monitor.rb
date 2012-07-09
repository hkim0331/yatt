#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#
# yatt score server version 2
# programmed by hkim@melt.kyutech.ac.jp
# Copyright (C)2002-2012, Hiroshi Kimura.
#
# VERSION: 0.16.2
#
# update 2012-04-02, icome connection.
# 2012-04-22, rename yatt_server as yatt_monitor.
#

DEBUG=(RUBY_PLATFORM=~/darwin/)

def debug(s)
  puts s if DEBUG
end

require 'drb'
require 'sequel'

YATT_VERSION='0.16.2'
DATE='2012-05-11'

REQ_RUBY="1.9.3"
raise "require ruby>="+REQ_RUBY if (RUBY_VERSION<=>REQ_RUBY)<0
PORT=23002
BEST=30
if DEBUG
  HOSTNAME="localhost"
  LOG=File.join("../log",Time.now.strftime("%Y-%m-%d.log"))
  DS=Sequel.sqlite("../db/yatt.db")[:yatt]
  # DS=Sequel.connect('mysql2://yatt:yyy@localhost/yatt_test')[:yatt]
else
  HOSTNAME="edu.melt.kyutech.ac.jp"
  LOG="/usr/local/var/log/yatt.log"
  DS=Seqluel.connect('mysql2://yatt:yyy@localhost/yatt_production')[:yatt]
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

  --authdir dir
  (no work. remain compatibility only.)
        use dir to authenticate yatt users.
        the dir must contain files whose name is equal
        to user id. only permit uses can join contest.
        authdir's default value is yatt_server's working dir.

  --noauth
  (no work. remain compatibility only.)
        do not authenticate.
        in other words, return true for all queries.

  --log file
        log yatt/yatt_server communication into file.
        file must be gives as an absolute path(../log/yyyy-mm-dd.log).

  --debug
        debug mode.

EOF
  exit 1
end

class ScoreServer
  attr_reader :score

  # FIXME: sqlite3=>mysql
  def initialize(logfile)
    @score=Hash.new(0)
    @logfile=logfile
    @ds=DS
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
  def put(name,score,time)
    debug ("#{__method__}: #{name}, #{score}, #{time}")
    File.open(@logfile,"a") do |fp|
      fp.puts "#{time} #{name} #{score}"
    end
    @ds.insert(:uid=>name,:score=>score,
      :updated_at=>Time.now.strftime("%Y-%m-%d %H:%M:%S"))
    if score>@score[name][0]
      @score[name]=[score, time]
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
      @score[who]=[score.to_i, time]
    end
  end

  def rank(name)
    pt=@score[name][0]
    length=0
    rank=1
    @score.each_value do |val|
      length+=1
      rank+=1 if val[0]>pt
    end
    if rank==1
      "You are the champ now."
    else
      "#{name}: #{pt} (#{rank}/#{length})"
    end
  end

  # CHANGED: return array
  def get(num)
    debug("#{__method__}: #{num}")
    self.best(num)
  end

  # 2012-05-09, c-2g で詰まった。原因は sqlite3 か、drb か?
  def get_global(num)
    ret=Hash.new
    @ds.each do |r|
      uid=r[:uid]
      if ret[uid].nil? or ret[uid][0]<r[:score]
        ret[uid]=[r[:score], r[:updated_at].strftime("%m/%d %H:%M")]
      end
    end
    ret.to_a.sort{|a,b| b[1][0] <=> a[1][0]}
  end

  # id の前から4文字マッチを取る
  def get_myclass(num,me)
    pat=%r{#{me[0,4]}}
    ret=Hash.new
    @ds.each do |r|
      uid=r[:uid]
      if uid=~ pat and (ret[uid].nil? or ret[uid][0]<r[:score])
        ret[uid]=[r[:score], r[:updated_at].strftime("%m/%d %H:%M")]
      end
    end
    ret.to_a.sort{|a,b| b[1][0] <=> a[1][0]}
  end

  def remove(me)
    self.del(me)
  end

  def reload
  end

  def my_rank(me)
    self.rank(me)
  end

  def ping
    "ok"
  end

  def auth(id)
    true
  end

end #ScoreServer

#
# main
#

hostname="localhost"
port=PORT
logfile=LOG

while (arg=ARGV.shift)
  case arg
  when /\A--server\Z/
    hostname=ARGV.shift
  when /\A--port\Z/
    port=ARGV.shift.to_i
  when /\A--log\Z/
    logfile=ARGV.shift
  when /\A--(fqdn|hostname|server)\Z/
    hostname=ARGV.shift
  when /\A--authdir\Z/
    authdir=ARGV.shift
  when /\A--noauth\Z/
    authdir=nil
  # 2012-07-09, mysql migration. no use.
  when /\A--db/
    db=ARGV.shift
  else
    usage
  end
end
debug([YATT_VERSION, hostname, port, db].join(", "))

begin
  score_server=ScoreServer.new(logfile)
  uri="druby://#{hostname}:#{port}"
  DRb.start_service(uri, score_server)
  puts uri
  DRb.thread.join

rescue =>e
  puts "#{e.class}:#{e.message}"
end

