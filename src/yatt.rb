#!/usr/bin/env ruby
#-*- coding: utf-8 -*-
#
# yatt: yet another typing trainer
# programmed by Hiroshi.Kimura@melt.kyutech.ac.jp
# Copyright (C) 2002-2012 Hiroshi Kimura.
#
# VERSION: 0.12
#
# 2009-04-13, config changed.
# 2012-03-24, update for ruby1.9.
# 2012-04-02, server updates.

$MYDEBUG=false

DEBUG=false

def debug(s)
  puts s if DEBUG
end

require 'tk'

# for standalone use
begin
  require 'drb'
  DRB_ENABLED=true
rescue
  STDERR.puts "you can not join contest without drb installed."
  DRB_ENABLED=false
end

YATT_VERSION='0.12'
DATE='2012-04-11'

REQ_RUBY="1.9.3"
raise "require ruby>="+REQ_RUBY if (RUBY_VERSION<=>REQ_RUBY)<0

GOOD="green"
BAD="red"

LIB="/Users/hkim/Library/yatt"
YATT_TXT="yatt.txt"
YATT_IMG="yatt.gif"

YATTD="localhost"
PORT=23002
RANKER=30

if DEBUG
  TIMEOUT=20
else
  TIMEOUT=60
end

# Use?
ADMIN="yatt"
ADMIN_DIR="/home/t/hkim"

#############
# FIXME:
# for windows version. Windows lacks ENV[].
module MyEnv
  def my_env(var)
    ENV[var]
  end
end

#############
class Trainer
  include MyEnv

  @epilog=false
  def about
    message="Yet Another Typing Trainer\n"+
      "(version "+YATT_VERSION+", "+DATE+")\n"+
      "programmed by\n Hiroshi.Kimura@melt.kyutech.ac.jp\n"+
      "Copyright (C) 2002-2012.\n"
    TkDialog.new(:title=>'yatt',
                 :message=>message,
                 :buttons=>['continue'])
  end

  def readme
    if RUBY_PLATFORM=~/linux/
      system("emacs #{README} &")
    else
      toplevel=TkToplevel.new{title 'YATT readme'}
      frame1=TkFrame.new(toplevel)
      frame1.pack
      text=TkText.new(frame1)
      text.configure(:width=>30,
                     :height=>20)
      text.pack(:side=>'right')
      scr=TkScrollbar.new(frame1)
      scr.pack(:side=>'left',:fill=>'y')
      text.yscrollbar(scr)
      File.foreach(README) do |line|
        text.insert('end',line)
      end
      text.configure(:state=>'disabled')
    end
  end

  def initialize(server,port,lib)
    @server=server
    @port=port
    @lib=lib

    @windows=nil
    @conf_dir=File.join(my_env('HOME'),".yatt")
    @user_config=File.join(@conf_dir,"config")
    @admin_config=File.join(ADMIN_DIR,".yatt","admin")
    @history="history"
    @width=78
    @lines=6
    @textfile=File.join(@lib,YATT_TXT)
    @splash  =File.join(@lib,YATT_IMG)
    @readme  =File.join(@lib,"yatt.README")

    @runnable_before="25:00"
    @contest=false
    @speed_meter_status=true
    @myid = my_env('USER')

    srand($$)
    Dir.mkdir @conf_dir unless File.directory?(@conf_dir)
    root=TkRoot.new{title 'yet another type trainer'}
    root.bind('KeyPress',proc{|e| key_press(e)},'%N')
    do_menu(root)
    base=TkFrame.new(root, :relief=>'groove', :borderwidth=>2)
    base.pack
    @textarea=MyText.new(base,
      :background=>'white',
      :width=>@width,
      :height=>@lines+1)
    @font="Courier"
    @size="14"
    my_set_font()
    @textarea.pack

    meter_frame=TkFrame.new(root)
    meter_frame.pack
    @speed_meter=SpeedMeter.new(meter_frame)
    @speed_meter.pack(:side=>'left')

    @scale=TkScale.new(meter_frame,
      :orient=>'horizontal',
      :length=>600,
      :from=>0,
      :to=>TIMEOUT,
      :tickinterval=>TIMEOUT/2)
    @scale.pack(:fill=>'x')

    graph_frame=TkFrame.new(root,:relief=>'groove',:borderwidth=>2)
    graph_frame.pack
    @stat=MyStatus.new(graph_frame,@splash)
    @stat.pack(:side=>'left')

    @scoreboard=Scoreboard.new(graph_frame,@server,@port, @contest)
    @scoreboard.pack(:expand=>1,:fill=>'both')
    @scoreboard.splash

    raise "#{@textfile} does not exist " unless File.file?(@textfile)
    @doclength=0
    File.foreach(@textfile) do |line|
      @doclength+=1
    end
    debug "@doclength=#{@doclength}"
    insert(@textfile,@lines)
  end

  def do_menu(root)
    menu_frame=TkFrame.new(root,:relief=>'raised',:bd=>1)
    menu_frame.pack(:side=>'top',:fill=>'x')
    menu=[
      [['File',0],
        ['New', proc{menu_new},0],
        #       ['Pref'],
        ['Quit',proc{menu_quit},0]],
      [['Misc',0],
        ['Contest',proc{menu_toggle_contest},0],
        ['reLoad', proc{menu_reload},2],
        ['My ranking', proc{menu_my_rank},0],
        ['Remove me',proc{menu_remove_me},0],
        ['show All participant',proc{menu_show_all},5],
        '---',
        ['Sticky',proc{menu_sticky},0],
        ['Loose',proc{menu_loose},0],
        ['Default',proc{menu_default},0],
        '---',
        ['Percentile graph', proc{menu_percentile},0],
        '---',
        ['Speed Meter',proc{menu_speed_meter},0],
        ['Today\'s score', proc{menu_todays_score},0],
        ['total Score',proc{menu_total_score},6]],
      [['Font',0],
        ['courier', proc{menu_setfont('Courier')}],
        ['fixed', proc{menu_setfont('Fixed')}],
        ['helvetica', proc{menu_setfont('Helvetica')}],
        ['menlo', proc{menu_setfont('Menlo')}],
        ['mincho', proc{menu_setfont('Mincho')}],
        ['monaco', proc{menu_setfont('Monaco')}],
        ['sazanami', proc{menu_setfont('Sazanami')}],
        ['times', proc{menu_setfont('Times')}],
        '---',
        ['10', proc{menu_setsize(10)}],
        ['12', proc{menu_setsize(12)}],
        ['14', proc{menu_setsize(14)}],
        ['18', proc{menu_setsize(18)}],
        ['24', proc{menu_setsize(24)}],
        ['34', proc{menu_setsize(34)}],
        '---',
        ['save font']],
      [['Help',0],
        ['readme', proc{readme},0],
        ['about...',proc{about},0],
        '---',
        ['parameters', proc{show_params},0],
        ['debug',proc{menu_debug}]]]
    TkMenubar.new(menu_frame, menu).pack(:side=>'top',:fill=>'x')
  end

  def show_params
    message =
      "ruby: #{RUBY_VERSION}\n"+
      "version: #{YATT_VERSION}\n"+
      "date: #{DATE}\n"+
      "lib: #{LIB}\n"+
      "admin: #{ADMIN_DIR}\n"+
      "server: #{@server}\n"+
      "port: #{@port}\n"
    TkDialog.new(:title=>'yatt params',
                 :message=>message,
                 :buttons=>['continue'])
  end

  def menu_new
    @timer.cancel
    insert(@textfile,@lines)
  end

  def menu_quit
    @logger.save_and_quit(File.join(@conf_dir,@history))
    exit(0)
  end

  def menu_sticky
    @textarea.sticky
  end

  def menu_loose
    @textarea.loose
  end

  def menu_default
    @textarea.set_loose(false)
    @textarea.set_sticky(false)
  end

  def menu_toggle_contest
    if @scoreboard.auth(@myid)
      @contest = @scoreboard.toggle_contest(@myid)
      @logger.clear_highscore
    else
      TkDialog.new(:title=>'yatt server',
                   :message=>"FAIL:\n#{@myid} does not belong to this class.",
                   :buttons=>'continue')
    end
  end

  def menu_reload
    @scoreboard.update
  end

  def menu_my_rank
    @scoreboard.rank(@myid)
  end

  def menu_remove_me
    @scoreboard.remove(@myid)
  end

  def menu_show_all
    @scoreboard.show_all
  end

  def menu_speed_meter
    @speed_meter.config(@speed_meter_status = ! @speed_meter_status)
  end

  def menu_todays_score
    t=Time.now
    today=t.strftime("%m%d")
    lst=[]
    File.foreach(File.join(@conf_dir, today)) do |line|
      lst.push(line.chomp.to_i)
    end
    @todays=MyPlot.new(today)
    @todays.clear
    @todays.plot(lst)
  end

  def menu_total_score
    lst=[]
    File.foreach(File.join(@conf_dir, @history)) do |line|
      point, rest=line.split(/\s+/)
      lst.push(point.to_i)
    end
    @total=MyPlot.new("total")
    @total.clear
    @total.plot(lst)
  end

  def menu_setfont(name)
    @font=name
    my_set_font()
  end

  def menu_setsize(size)
    @size=size
    my_set_font()
  end

  def my_set_font()
    @textarea.configure(:font=>"#{@font} #{@size}")
  end

  def menu_percentile
    @stat.percentile
  end

  def menu_debug
    $MYDEBUG = !$MYDEBUG
  end

  def insert(file, num_lines)
    if ! time_for_train?(Time.now, @runnable_before)
      STDERR.puts "it's not the time for training.\n"
      exit
    end

    # reset session parameters
    @line=0
    @char=0
    @epilog=false
    @time_remains=TIMEOUT
    @wait_for_first_key=true

    start=rand(@doclength-2*num_lines) # 2 for programming ease.
    debug "start: #{start}"
    @text=[]
    File.open(file,"r") do |fp|
      # read off 'start' lines
      start.times do
        fp.gets
      end
      # readin 'num_lines'
      num_lines.times do
        @text.push fp.gets
      end
    end

    @textarea.insert(@text.join)
    @textarea.highlight("good",@line,@char)
    @scale.set(TIMEOUT)
    @logger=Logger.new
    @num_chars=0
    tick=1000
    interval=tick/1000 # interval==1
    @timer=TkAfter.new(tick, #msec
      -1,    #forever
      proc{
        if (@time_remains<0 or self.finished?)
          @timer.cancel
        elsif (! @wait_for_first_key)
          @scale.set(@time_remains-=interval)
          @speed_meter.plot(@num_chars) if @speed_meter_status
          @num_chars=0
        end
      }).start
  end

  def time_for_train?(now,crit)
    return false if File.exists?(File.join(ADMIN_DIR,".yatt","do_not_run"))
    hour,min=crit.split(/:/)
    now.hour*60+now.min < hour.to_i*60+min.to_i
  end

  # core of yatt.rb
  # rewrite 2002.06.08
  # does not work in ruby19.
  def key_press(key)
    return if @epilog
    key &= 0x00ff
#    debug key
    return if (key==0 or key>128) # shift, control or alt. do nothing
    if @wait_for_first_key
      @wait_for_first_key=false
      @logger.start
    end
    @num_chars+=1
    if (@time_remains<0) or (@line>=@lines) # session ends
      @logger.finish    # stop KeyPress event ASAP
      epilog
      return
    end
    c=key.chr
    case target=@text[@line][@char]
    when "\n"
      if (key==0x0d) #match
        @logger.add_good(target)
        @textarea.unlight(@line,@char)
        @line+=1
        @char=0
        if finished?
          @logger.finish
          @logger.complete=true
          epilog
          return
        end
        @textarea.highlight("good",@line,@char)
      else
        @logger.add_ng(target,key)
        @textarea.highlight("bad",@line,@char)
        if @textarea.value_loose
          @line += 1
          @char=0
          @textarea.highlight("good",@line,@char)
        end
      end# when "\n"
    when c    # match
      @logger.add_good(target)
      @textarea.unlight(@line,@char)
      @char+=1
      @textarea.highlight("good",@line,@char)
    else # not match
      @logger.add_ng(target,key)
      @textarea.highlight("bad",@line,@char)
      if @textarea.value_loose
        @char += 1
        @textarea.highlight("good",@line,@char)
      end
    end
  end#key_press

  def finished?
    @line==@lines
  end

  def epilog
    @epilog=true
    # moved here from bottom of this method.
    while (@timer.running?)
      @timer.stop
    end
    #
    score=@logger.score
    strokes=@logger.goods+@logger.bads
    errors=(((@logger.bads.to_f/@logger.goods.to_f)*1000).floor).to_f/10
    msg = "#{score} points in #{@logger.diff_time} second.\n"+
      "strokes: #{strokes}\n"+
      "errors:  #{errors}%\n"
    if (errors>3.0)
      msg += "\nError-rate is too high.\nYou have to achieve 3.0%.\n"
    end
    if c=@logger.complete?
      score +=100
      msg += "+ bonus complete (100)\n"
      score += (tr=@time_remains*50)
      msg += "+ bonus time remains (#{tr})\n"
    end
    if p=@logger.perfect?
      score +=300
      msg += "+ bonus perfect (300)\n"
    end
    msg += "becomes #{score}!!!\n" if (c or p)

    @logger.save(score,@conf_dir)
    @logger.accumulate
    @stat.plot(@logger.sum_good,@logger.sum_ng)

    if $MYDEBUG
      STDERR.puts "contest:#{@contest}, auth:#{@scoreboard.authenticated}"
    end

    if score > @logger.highscore
      @logger.set_highscore(score)
      if (@contest and @scoreboard.authenticated)
        @scoreboard.submit(@myid,score)
      end
    end
    @scoreboard.update if @contest
    ret=TkDialog.new(:title=>'yet another type trainer',
                     :message=>msg,
                     :buttons=>'continue').value
    sleep(1)
    insert(@textfile, @lines)
    @epilog=false
    sleep(1)
  end #epilog
end #Trainer

#####################
class MyText < TkText
  @@sticky=false
  @@loose=false
  def initialize(parent, params)
    @text=TkText.new(parent,params)
    @text.tag_configure('good',:background=>GOOD)
    @text.tag_configure('bad',:background=>BAD)
  end

  def insert(text)
    @text.configure(:state=>'normal')
    @text.delete('1.0','end')
    @text.insert('end',text)
    @text.configure(:state=>'disabled')
  end

  def pack
    @text.pack
  end

  def highlight(stat,line,char)
    pos=(line+1).to_s+"."+char.to_s
    @text.tag_add(stat,pos)
  end

  def unlight(line,char)
    pos=(line+1).to_s+"."+char.to_s
    @text.tag_remove('good',pos)
    @text.tag_remove('bad',pos) unless @@sticky
  end

  def sticky
    @@sticky = !@@sticky
  end

  def loose
    @@loose = !@@loose
  end

  def value_loose
    @@loose
  end

  def set_sticky(value)
    @@sticky=value
  end

  def set_loose(value)
    @@loose=value
  end

  def configure(param)
    @text.configure(param)
  end
end #MyText

############
class Logger
  include MyEnv

  @@sum_good=Hash.new(0)
  @@sum_ng=Hash.new(0)
  @@highscore=0

  def sum_good
    @@sum_good
  end
  def sum_ng
    @@sum_ng
  end

  attr_reader :good, :ng, :start_time, :finish_time, :complete
  attr_writer :complete

  def initialize
    @good=Hash.new(0)
    @ng=Hash.new(0)
    t=Time.now
    @today=t.strftime("%m%d")
  end

  def start
    @start_time=Time.now
    @complete=false
  end

  def finish
    @finish_time=Time.now
  end

  def add_ng(target,key)
    @ng[target]+=1
  end

  def add_good(target)
    @good[target]+=1
  end

  def diff_time
    ((@finish_time-@start_time)*10).to_i/10.0
  end

  def complete?
    @complete
  end

  def perfect?
    @complete && (sum(@ng)==0)
  end

  def score
    debug=false
    w=0.3
    time=diff_time
    sum_good=sum(@good)
    sum_ng=sum(@ng)
    num_keys=sum_good+sum_ng
    return 0 if num_keys==0
    score=(w*sum_good*(sum_good.to_f/num_keys)**3*(num_keys/time)).floor
  end

  def highscore
    @@highscore
  end

  def set_highscore(score)
    @@highscore=score
  end

  def clear_highscore
    @@highscore=0
  end

  def goods
    sum(good)
  end

  def bads
    sum(ng)
  end

  def sum(hsh)
    s=0
    hsh.each_value do |x|
      s+=x
    end
    s
  end

  def accumulate
    @good.each do |key,value|
      @@sum_good[key]+=value
    end
    @ng.each do |key,value|
      @@sum_ng[key]+=value
    end
  end

  def audit
    STDERR.puts "----------"
    (@@sum_good.keys | @@sum_ng.keys).sort.each do |key|
      STDERR.puts "#{key.chr}:#{@@sum_good[key]}:#{@@sum_ng[key]}\n"
    end
  end

  def save(score,dir)
    fp=File.open(File.join(dir,@today),"a")
    fp.puts(score)
    fp.close
  end

  def save_and_quit(file)
    fp=File.open(file,"a+")
    fp.puts @@highscore.to_s+"\t"+Time.now.asctime
    fp.close
  end
end #Logger

########################
class MyStatus <TkCanvas
  include MyEnv
  # WIDTH, etc., must be calculated from the width of `text' area.
  # How should I do?
  WIDTH=420
  HEIGHT=200
  C_WIDTH=10
  C_HEIGHT=20

  def initialize(parent,splash)
    @graph=TkCanvas.new(parent,
                        :width=>WIDTH,
                        :height=>HEIGHT,
                        :background=>'white')
    if FileTest.exists?(splash)
      img=TkPhotoImage.new(:file=>splash)
      TkcImage.new(@graph,WIDTH/2,130,:image=>img)
    end
    @percentile=false
  end

  def percentile
    @percentile = !@percentile
  end

  def pack(params)
    @graph.pack(params)
  end

  def plot(good, bad)
    @graph.delete("all")
    keys = (good.keys | bad.keys).sort
    return if keys.length<2
    dx=(WIDTH-2*C_WIDTH).to_f/(keys.length-1) # -1 for ' '
    max=0
    keys.each do |key|
      next if key.chr==' '      # do not display ' '
      n=good[key]+bad[key]
      max=n if n>max
    end
    ratio=(HEIGHT-C_HEIGHT*2).to_f/max
    ox=C_WIDTH
    oy=HEIGHT-C_HEIGHT
    half_x=dx/2
    base_y=HEIGHT-C_HEIGHT/2
    while (key=keys.shift)
      next if key.chr==' '      # do not display ' '
      if (@percentile)
        n=good[key]+bad[key]
        rect(ox,oy,good[key].to_f*max/n,bad[key].to_f*max/n,dx,ratio)
      else
        rect(ox,oy,good[key],bad[key],dx,ratio)
      end
      text(ox+half_x,base_y,key)
      ox+=dx
    end
  end

  def rect(x,y,good,bad,dx,ry)
    TkcRectangle.new(@graph,x,y,x+dx,y-good*ry,:fill=>GOOD)
    TkcRectangle.new(@graph,x,y-good*ry,x+dx,y-(good+bad)*ry,:fill=>BAD)
  end

  def text(x,y,char)
    TkcText.new(@graph,x,y,:text=>char.chr)
  end
end # Status

################
class Scoreboard
  include MyEnv

  WIDTH=30
  HEIGHT=10

  attr_reader :authenticated

  def initialize(parent, server, port, stat)
    @text=TkText.new(parent,
                     :takefocus=>0,
                     :background=>'gray',
                     :width=>WIDTH,
                     :height=>HEIGHT,
                     :state=>'disabled')
    @stat=stat
    @scr=TkScrollbar.new(parent)
    @text.yscrollbar(@scr)
    highlight("highlight")
    @server=server
    @port=port
    @my_id=my_env('USER')
    @authenticated=false
    self.start_drb unless @server
  end

  def start_drb
    begin
      DRb.start_service()
      @obj=DRbObject.new(nil, "druby://#{@server}:#{@port}")
      true
    rescue DRb::DRbConnError
      self.can_not_talk(@server)
      @obj=nil
      false
    end
  end

  def can_not_talk(server)
    TkDialog.new(:title=>'scoreboard daemon',
                 :message=>"scoreboard is not available at #{server}.\n"+
                 "you can not join contest.",
                 :buttons=>['continue'])
  end

  def pack(param)
    @scr.pack(:side=>'left',:fill=>'y')
    @text.pack(param)
  end

  def destroy
    return if @obj.nil?
    @obj=nil
  end

  def highlight(color)
    @text.tag_configure("highlight",
                        :background=>"red",:foreground=>"white")
  end

  def remove(user)
    return if @obj.nil?
    @obj.remove(user) and self.update
  end

  def splash
    @text.configure(:state=>'normal')
    @text.delete('1.0','end')
    @text.insert('end',
                 "= Realtime Typing Contest =\n\n"+
                 "choose contest from \n"+
                 "Misc menu to join.\n\n"+
                 "last modified:\n" + DATE)
    @text.configure(:state=>'disabled')
  end

  # changed: rankers is an array. [[hkim, [65, "2012-04-02"]]]
  def display(rankers)
    debug "#{__method__}: rankers=#{rankers}"
    if (rankers.empty?)
      debug "rankers emty."
      @text.configure(:state=>'normal')
      @text.delete('1.0','end')
      @text.insert('end',"no entry.")
      @text.configure(:state=>'disabled')
    else
      line=1
      my_entry=0
      ranking=""
      rankers.each do |data|
        debug "#{data}"
        ranker,point_date=data
        point,date=point_date
        ranking<< "%2s" % line + "%5s" % point + " " +"%-10s" % ranker +
        "%5s" % date+"\n"
        my_entry=line if @my_id=~/#{ranker}/
        line+=1
      end
      @text.configure(:state=>'normal')
      @text.delete('1.0','end')
      @text.insert('end',ranking)

      # hilight his entry
      @text.tag_add("highlight","#{my_entry}.0","#{my_entry}.end") unless
      my_entry==0

      @text.configure(:state=>'disabled')
    end
  end

  def bgcolor(color)
    @text.configure(:state=>'normal')
    @text.configure(:background=>color)
    @text.configure(:state=>'disabled')
  end

  def update
    return if @obj.nil?
    display(@obj.get(RANKER))
  end

  def rank(user)
    return if (@obj.nil?)
    if (ans=@obj.my_rank(user))
      TkDialog.new(:title=>'your ranking',
                   :message=>"#{user}: #{ans}",
                   :buttons=>['continue'])
    else
      self.can_not_talk(@server)
    end
  end

  def submit(myid, score)#2003.06.30
    STDERR.puts "submit: #{myid}, #{score}" if $MYDEBUG
    return if @obj.nil?
    month_date=Time.now.strftime("%m/%d %H:%M")
    @obj.put(myid,score,month_date)
  end

  def toggle_contest(uid)
    return false if @obj.nil?
    @stat = ! @stat
    if (@stat)
      #clear self's point
      self.bgcolor('white')
      self.update
    else
      self.bgcolor('gray')
      self.splash
    end
    @stat
  end

  def show_all
    return if @obj.nil?
    display(@obj.all)
  end

  def auth(uid)
    debug "#{__method__}: #{uid}"
    @authenticated=if (! @obj.nil?)
                      @obj.auth(uid)
                   else
                      self.start_drb and self.auth(uid)
                   end
  end
end # Scoreboard

############
class MyPlot
  WIDTH=300
  HEIGHT=200
  SHRINK=0.86
  MX=30
  MY=10
  R=5

  def initialize(title)
    @toplevel=TkToplevel.new(:title=>title)
    @graph=TkCanvas.new(@toplevel,
                        :width=>WIDTH,
                        :height=>HEIGHT)
    @graph.pack
  end

  def plot(lst)
    len=lst.length
    max=0
    lst.each do |item|
      max=item if item > max
    end
    dx=(WIDTH-MX*2).to_f/len
    ratio=SHRINK*(HEIGHT-MY).to_f/max
    x_axes(WIDTH-MX)
    y_axes(max, ratio)
    lst=lst.map {|y| (HEIGHT-MY)-y*ratio}
    x=MX
    while (y=lst.shift)
      TkcOval.new(@graph,x,y,x+R,y-R,:outline=>'red',:fill=>'red')
      x+=dx
    end
  end

  def x_axes(max)
    TkcLine.new(@graph,MX,HEIGHT-MY,max,HEIGHT-MY)
  end

  def y_axes(max,ratio)
    TkcLine.new(@graph,MX,HEIGHT-MY,MX,MY)
    TkcText.new(@graph,MX/2,HEIGHT-max*ratio,:text=>max.to_s)
    TkcText.new(@graph,MX/2,HEIGHT-MY, :text=>'0')
  end

  def clear
    @graph.delete("all")
  end

  def replot(lst)
    clear
    plot(lst)
  end
end # MyPlot

################
class SpeedMeter
  include Math
  WIDTH=50
  HEIGHT=40
  MAX=14

  def config(stat)
    if (stat)
      plot(0)
    else
      clear
    end
  end

  def initialize(parent)
    @canvas=TkCanvas.new(parent,
                         :width=>WIDTH,
                         :height=>HEIGHT,
                         :takefocus=>0)
    r=(WIDTH/2)*0.8
    pi=3.14
    @xy=(0..MAX).map{|n| [r*cos(pi-n*pi/MAX), r*sin(pi-n*pi/MAX)]}
    @ox=WIDTH/2
    @oy=HEIGHT*0.8
    plot(0)
  end

  def pack(params)
    @canvas.pack(params)
  end

  def clear
    @canvas.delete('all')
  end

  def plot(n)
    clear
    n=min(n,MAX)
    x,y=@xy[n]
    TkcLine.new(@canvas,@ox,@oy,@ox+x,@oy-y,
                :width=>2,:fill=>'red')
    TkcOval.new(@canvas,@ox-2,@oy-2,@ox+2,@oy+2,:fill=>'black')
  end

  def min(m,n)
    if m<n
      m
    else
      n
    end
  end
end# SpeedMeter
#
# main
#
server=YATTD
port=PORT
lib=LIB
while (arg=ARGV.shift)
  case arg
  when /--server/
    server=ARGV.shift
  when /--port/
    port=ARGV.shift
  when /--lib/
    lib=ARGV.shift
  when /--noserver/
    server=nil
  else
    usage()
  end
end
trainer=Trainer.new(server, port, lib)
Tk.mainloop

#Local Variables:
#mode: Ruby
#End:
