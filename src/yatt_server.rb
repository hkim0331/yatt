#!/usr/bin/env ruby
#-*- coding: utf-8 -*-
#
# yatt score server version 2
# programmed by hkim@melt.kyutech.ac.jp
# Copyright (C)2002-2012, Hiroshi Kimura.
#
# VERSION: 0.11
#
# update 2012-04-02, icome connection.

DEBUG=false

def debug(s)
  puts s if DEBUG
end

require 'drb'
require 'sequel'

YATTD_VERSION="0.4"
DATE="2012-04-02"
REQ_RUBY="1.9.3"
raise "require ruby>="+REQ_RUBY if (RUBY_VERSION<=>REQ_RUBY)<0
HOSTNAME="localhost"
PORT=23002
BEST=30
LOG=File.join("../log",Time.now.strftime("%Y-%m-%d.log"))
DB="../db/yatt.db"

def usage
  print <<EOF
USAGE
  yatt_server [OPTION]...

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

  def initialize(logfile, db)
    @score=Hash.new(0)
    @logfile=logfile
    @db=Sequel.sqlite(db)
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

  def put(name,score,time)
    debug ("#{__method__}: #{name}, #{score}, #{time}")
    File.open(@logfile,"a") do |fp|
      fp.puts "#{time} #{name} #{score}"
    end
    @db[:yatt].insert(:uid=>name,:score=>score,
      :updated_at=>Time.now.strftime("%Y-%m-%d %H:%M:%S"))
    if score>@score[name][0]
      @score[name]=[score, time]
    end
  end

  def del(name)
    @score.delete(name)
  end

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

  # return array
  def get(num)
    debug("#{__method__}: #{num}")
    debug "#{self.best(num)}"
    self.best(num)
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
db=DB

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
  when /\A--db/
    db=ARGV.shift
  else
    usage
  end
end
debug([YATTD_VERSION, hostname, port, db].join(", "))

begin
  score_server=ScoreServer.new(logfile, db)
  uri="druby://#{hostname}:#{port}"
  DRb.start_service(uri,score_server)
  puts uri
  DRb.thread.join

rescue =>e
  puts "#{e.class}:#{e.message}"
end

