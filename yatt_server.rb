#!/usr/bin/ruby
# yatt score server version 2
# programmed by hkim@melt.kyutech.ac.jp
# Copyright (C)2002-2005, Hiroshi Kimura

YATTD_VERSION="0.3.5"
DATE="2005.06.08"

REQ_RUBY="1.8.2"
raise "require ruby>="+REQ_RUBY if (RUBY_VERSION<=>REQ_RUBY)<0

require 'drb' or raise "score server depends on drb"

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
        use dir to authenticate yatt users.
        the dir must contain files whose name is equal
        to user id. only permit uses can join contest.
        authdir's default value is yatt_server's working dir.

  --noauth
        do not authenticate.
        in other words, return true for all queries.

  --log file
        log yatt/yatt_server communication into file.
        file must be gives as an absolute path(./%y%m%d.log).

  --debug
        debug mode.

EOF
exit 1
end


HOSTNAME="localhost"
PORT=23002

AUTH_DIR=File.join(".","user.allow")
LOG=File.join(".",Time.now.strftime("%y%m%d.log"))

BEST=30

class Logger
  @@logfile_defined=false
  attr_reader :logfile
  def initialize(name)
    if (@@logfile_defined)
      STDERR.puts("logfile #{@logfile} already defined.\n")
      exit(1)
    end
    @logfile=name
    @fp=File.new(@logfile,"w")
  end

  def puts(host, s)
    wday, month, day, clock, tz, year=Time.now.to_s.split(/ /)
    @fp.puts "#{month} #{day} #{clock} [#{host}] #{s}"
    @fp.flush
  end

  def stop
    @fp.close
  end
end

class ScoreServer
  attr_reader :score

  def initialize(db)
    @score=Hash.new(0)
    @students=Array.new

    # for authentication
    if db.nil?
      # no auth
      @auth=false
      return
    end

    raise "authdir #{db} does not exist." unless FileTest.exists?(db)

    Dir.foreach(db) do |uid|
      next if uid=~/^\./
      uid=uid.chomp
      @students.push(uid)
      STDERR.puts "allow: #{uid}" if $DEBUG
    end
    @auth=true
  end

  def clear
    @score.clear
  end

  def best(n)
    orig=$,
    $,=','
    result=@score.sort{|a,b| b[1][0]<=>a[1][0]}[0..n-1].to_s
    $,=orig
    result
  end

  def all
    best(@score.length)
  end

  def put(name,score,time)
    STDERR.puts "put: #{name}, #{score}, #{time}" if $DEBUG
    if score>@score[name][0]
      @score[name]=[score, time]
    end
  end

  def del(name)
    @score.delete(name)
  end

  def dump(name)
    fp=File.new(name,"w+")
    fp.puts "# #{$0} dump #{Time.now}\n"
    @score.each do |who, score,time|
      fp.puts "#{who}\t#{score}\t#{time}"
    end
    fp.close
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

#############
  def get(num)
    STDERR.puts "get: #{num}" if $DEBUG
    self.best(num)
  end

  def remove(me)
    self.del(me)
  end

  def auth(uid)
    return true unless @auth
    return true if $DEBUG
    return @students.include?(uid)
  end

  def reload
  end

  def my_rank(me)
    self.rank(me)
  end

  def ping
    "ok"
  end

  def start

  end

  def quit

  end
end #ScoreServer

#
# main
#
port=PORT
logfile=LOG
hostname="localhost"
authdir=AUTH_DIR

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
  else
    usage
  end
end

STDERR.puts [YATTD_VERSION, hostname, port,authdir].join(", ") if $DEBUG

begin
  score_server=ScoreServer.new(authdir)
  DRb.start_service("druby://#{hostname}:#{port}",score_server)
  DRb.thread.join
rescue Interrupt
  score_server.dump(logfile)
  exit 0
end

#Local Variables:
#mode: Ruby
#End:
