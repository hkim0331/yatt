#!/usr/bin/env ruby
#-*- coding: utf-8 -*-
#
# yatt_probe - realtime ranking board frontend for YATT
# programmed by Hiroshi.Kimura@melt.kyutech.ac.jp
# Copyright (C) 2002-2008,  Hiroshi Kimura
# debug: 2008-06-17,

$MYDEBUG=true

def usage
STDERR.print <<EOF
USAGE:
    yatt_probe.rb [OPTIONS]

OPTIONS

(*) are unimplemented yet.

    --clear(*)
        clear yatt_server record

    --color color
        tk will use  'color' to display.

    --dump /path/to/the/file

    --interval s
        poll yatt_server every second s.

    --length n
        fetch n entries.

    --load /path/to/the/file (*)

    --loop l
        update l times and exit.

    --one-shot
        force --without-x --length 9999

    --port port_number

    --server name

    --with-x
        display using TK widget.

    --without-x
        display to stdout.

EOF
exit(1)
end

require 'drb'

YATT_PROBE_VERSION="0.4.3"
DATE = '2017-03-19'

INTERVAL=30
HOW_MANY=10
WIDTH=20

WAIT_FOR_SERVER=3
SERVER="localhost"
PORT=23002

################
class Scoreboard
  def initialize(server,port,color,length,dump,x11)
    @server,@port,@color,@length,@dump=[server,port,color,length,dump]
    @x11=x11
    STDERR.puts [@server,@port,@color,@length,@dump].join("\n") if $MYDEBUG
    if (@x11)
      self.tkinit
    end
    DRb.start_service()
    @obj=DRbObject.new(nil,"druby://#{@server}:#{@port}")
  end

  def tkinit
    require 'tk'
    @root=TkRoot.new{title $0}
    menu=[[['File'],
        ['Clear',proc{my_clear},0],
        ['Get',proc{update},0],
        ['Dump',proc{my_dump},0],
        ['Load',proc{my_load},0],
#       ['New Key',proc{my_new_key},0],
        ['Quit',proc{@sock.close; exit},0]]]
    TkMenubar.new(@root,menu).pack('side'=>'top','fill'=>'x')

    scr=TkScrollbar.new(@root)
    scr.pack('side'=>'left','fill'=>'y')
    @text=TkText.new(@root,
                    'takefocus'=>0,
                    'background'=>'white',
                    'width'=>WIDTH,
                    'height'=>HOW_MANY)
    @text.pack
    @text.yscrollbar(scr)
    @color=false
  end

  def update
    display(@obj.get(@length))
  end

  def my_clear
    @obj.clear
    self.update
  end

  def my_dump
    @obj.dump(@dump)
  end

  def my_load
    @obj.load(@dump)
    self.update
  end

  def set_color(color)
    @color=true
    @text.tag_configure("color","background"=>color) if @x11
  end

  def display(str)
    if @x11
      display_x11(str)
    else
      str.scan(/.+?,.+?,.+?,/).map{|x| x.gsub(/,/,"\t")}.each do |line|
        next if line.nil? # why nil appears in ?
        puts line
      end
    end
  end

  def display_x11(str)
    ranking=""
    buf=str.split(/,/)
    line=1
    while (ranker=buf.shift)
      point=buf.shift
      ranking<< "%2s" % line + "%5s" % point + " " +"%-10s" % ranker + "\n"
      line+=1
    end
    @text.configure('state'=>'normal')
    @text.delete('1.0','end')
    @text.insert('end',ranking)
    if @color
      (1..line).each do |n|
        @text.tag_add("color","#{n}.0","#{n}.end") if n%2 ==1
      end
    end
    @text.configure('state'=>'disabled')
  end

  def is_alive?
    alive=false
    thread=Thread.new {
      @obj.ping
      alive=true
    }
    sleep(WAIT_FOR_SERVER)
    thread.kill
    alive
  end
end # Scoreboard

def prompt()
  STDERR.print "probe> "
end

def dispatch_help()
  STDERR.puts "no help"
end

def dispatch(sb,line)
  cmd,arg=line.split(/\s/,2)
  case cmd
  when /exit/
    exit
  when /dump/
    sb.my_dump()
  when /load/
    sb.load(arg)
  else
    dispatch_help
  end
end

#
# main
#
server=SERVER
port=PORT
length=HOW_MANY
now=Time.now.strftime("%m%d%H%M")
dump="/tmp/yatt-#{now}"
interval=INTERVAL
color=false
loop=10000
one_shot=false

while (arg=ARGV.shift)
  case arg
  when /\A--help\Z/
    usage
  when/\A--server\Z/
    server=ARGV.shift
  when /\A--port\Z/
    port=ARGV.shift.to_i
  when /--color\Z/
    color=ARGV.shift
  when /--interval\Z/
    interval=ARGV.shift.to_i
  when /--length\Z/
    length=ARGV.shift.to_i
  when /--dump\Z/
    dump=ARGV.shift
  when /--with-x/
    with_x11=true
  when /--without-x|--no-x/
    with_x11=false
  when /--loop/
    loop=ARGV.shift.to_i
  when /--one-shot/
    one_shot=true
    with_x11=false
    loop=1
    length=99999 # means 'all'
  else
    raise "#{arg}: unknown option"
  end#case
end#while

sb=Scoreboard.new(server,port,color,length,dump,with_x11)

if (with_x11)
  thread=Thread.new{
    loop do
      sb.update
      sleep interval
    end
  }
  Tk.mainloop
elsif (one_shot)
  sb.update
else
#  while (true)
#    sb.update
#    loop -= 1
#    break unless loop>0
#    sleep interval
#  end
  prompt()
  while (cmd=STDIN.gets)
    dispatch(sb,cmd.strip)
    prompt()
  end
end
