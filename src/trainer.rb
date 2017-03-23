# coding: utf-8
# VERSION: 0.73

class Trainer
  def about
    TkDialog.new(:title => "Yet Another Typing Trainer",
                 :message => COPYRIGHT,
                 :buttons => ['continue'])
  end

  def readme
    toplevel = TkToplevel.new{title 'YATT readme'}
    frame1 = TkFrame.new(toplevel)
    frame1.pack

    text = TkText.new(frame1)
    text.configure(:width  => 40, :height => 30)
    text.pack(:side => 'right')

    scr = TkScrollbar.new(frame1)
    scr.pack(:side => 'left', :fill => 'y')
    text.yscrollbar(scr)
    File.foreach(README) do |line|
      text.insert('end', line)
    end
    text.configure(:state => 'disabled')
  end

  # 長すぎ。
  def initialize(druby, lib)
    @left_to_right = true

    @epilog = false
    @druby = druby
    @lib   = lib
    @myid  = ENV['USER']

    @windows = nil
    @width   = 78

    @text_all = File.open(File.join(@lib, YATT_TXT)) do |fp|
      fp.readlines
    end

    # to show @lines in yatt textarea
    @lines   = 6

    @splash  = File.join(@lib, YATT_IMG)
    @speed_meter_status = true
    @contest = false

    srand($$)
    root = TkRoot.new {title 'yet another typing trainer'}
    # hotfix 0.22.1
    root.bind('KeyPress', proc{|k,n| key_press(k,n)},'%k','%N')
    #
    do_menu(root)
    base = TkFrame.new(root, :relief => 'groove', :borderwidth =>2)
    base.pack
    @textarea = MyText.new(base,
                           :background => 'white',
                           :width  => @width,
                           :height => @lines + 1)
    @font = "Courier"
    @size = "14"
    if File.exists?(MY_FONT)
      File.foreach(MY_FONT) do |line|
        @font,@size=line.chomp.split
      end
    end
    my_set_font()
    @textarea.pack

    meter_frame = TkFrame.new(root)
    meter_frame.pack
    @speed_meter = SpeedMeter.new(meter_frame)
    @speed_meter.pack(:side => 'left')

    @scale = TkScale.new(meter_frame,
                       :orient => 'horizontal',
                       :length => 600,
                       :from   => 0,
                       :to     => TIMEOUT,
                       :tickinterval => TIMEOUT/2)
    @scale.pack(:fill =>'x')

    graph_frame = TkFrame.new(root,
                              :relief => 'groove',
                              :borderwidth => 2)
    graph_frame.pack
    @stat = MyStatus.new(graph_frame, @splash)
    @stat.pack(:side => 'left')

    @scoreboard = Scoreboard.new(graph_frame, @druby, @contest)
    @scoreboard.pack(:expand => 1,:fill => 'both')
    @scoreboard.splash

    insert()

    counts, points = trials()
    TkDialog.new(:title => "contest",
                 :message => "秘密練習以外は contest on にすること。\n
これまでに #{counts} 回、練習しました。\n
総合点は #{points} 点です。",
                 :buttons => ['start'])
    menu_toggle_contest()
  end

  def trials()
    counts = 0
    points = 0
    Dir.glob("#{YATT_DIR}/??-??").each do |fname|
      File.foreach(fname) do |line|
        counts += 1
        points += line.chomp.to_i
      end
    end
    [counts, points]
  end

  def do_menu(root)
    menu_frame = TkFrame.new(root,
                             :relief=>'raised',
                             :bd=>1)
    menu_frame.pack(:side=>'top',:fill=>'x')
    menu = [
      [['Yatt'],
       ['about...',proc{about},0],
       ['readme',proc{readme},0],
       ['debug', proc{show_params},0], # FIXME: debug on/off ができるように。
       '---',
       # ['New', proc{menu_new},0], # 新しいテキストを挿入する。
       # ['Pref'],
       ['Quit',proc{menu_quit},0]],
      [['Contest'],
       ['On/off',proc{menu_toggle_contest}],
       '---',
       ['weekly status', proc{menu_my_status}],
       ['Remove me',proc{menu_remove_me}], # cache からしか消えない。
       '---',
       # ['refresh', proc{menu_reload}], # スコアボードをリフレッシュする。
       ['total',proc{menu_global}],
       ['week',proc{menu_show_all}],
       ['class',proc{menu_myclass}]],
      [['Mode'],
       ['Sticky',proc{menu_sticky},0],
       ['Loose',proc{menu_loose},0],
       '---',
       ['Speed Meter',proc{menu_speed_meter},0]],
      [['Graph'],
       ['Percentile graph', proc{menu_percentile},0],
       '---',
       ['Today\'s scores', proc{menu_todays_score},0],
       ['Tootal Scores',proc{menu_total_score},6],
       ['Errors',proc{menu_errors},0]],
      [['Font'],
       ['courier', proc{menu_setfont('Courier')}],
       ['helvetica', proc{menu_setfont('Helvetica')}],
       ['Inconsolata', proc{menu_setfont('Inconsolata')}],
       ['menlo', proc{menu_setfont('Menlo')}],
       ['monaco', proc{menu_setfont('Monaco')}],
       ['osaka', proc{menu_setfont('Osaka')}],
       '---',
       ['smaller(-)', proc{menu_smaller()}],
       ['bigger (+)', proc{menu_bigger()}],
       '---',
       ['remember font', proc{menu_save_font()}],
       ['reset font', proc{menu_reset_font()}]]]
    TkMenubar.new(menu_frame, menu).pack(:side=>'top',:fill=>'x')
  end

  def show_params
    TkDialog.new(:title => 'yatt params',
                 :message =>"ruby: #{RUBY_VERSION}
version: #{YATT_VERSION}
date: #{DATE}
lib: #{LIB}
#{@druby}\n",
                 :buttons => ['continue'])
  end

  def menu_global
    @scoreboard.global
    @scoreboard.update
  end

  def menu_weekly
    @scoreboard.weekly
    @scoreboard.update
  end

  def menu_myclass
    @scoreboard.myclass
    @scoreboard.update
  end

  def menu_new
    @timer.cancel
    insert()
  end

  def menu_quit
    exit(0)
  end

  def menu_sticky
    @textarea.sticky
  end

  def menu_loose
    @textarea.loose
  end

  def menu_toggle_contest
    @contest = @scoreboard.toggle_contest(@myid)
    @logger.clear_highscore
  end

  def menu_reload
    @scoreboard.update
    sleep(1)
  end

  def menu_my_status
    @scoreboard.status(@myid, trials())
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

  def menu_score(data, title)
    myplot = MyPlot.new(title)
    myplot.clear
    myplot.plot(data)
  end

  def menu_todays_score
    lst = []
    File.foreach(TODAYS_SCORE) do |line|
      lst.push(line.chomp.to_i)
    end
    menu_score(lst,Time.now.strftime("%Y-%m-%d"))
  end

  def menu_total_score
    lst = []
    File.foreach(HISTORY) do |line|
      point, date = line.split(/\s+/)
      lst.push(point.to_i)
    end
    menu_score(lst, "total")
  end

  def menu_errors
    lst = []
    File.foreach(ACCURACY) do |line|
      point, date = line.split(/\s+/)
      lst.push(point.to_i)
    end
    menu_score(lst, "errors(%)")
  end

  def menu_setfont(name)
    @font = name
    my_set_font()
  end

  def menu_bigger()
    @size = [@size.to_i+2, 64].min.to_s
    my_set_font()
  end

  def menu_smaller()
    @size = [@size.to_i-2, 10].max.to_s
    my_set_font()
  end

  def menu_setsize(size)
    @size = size
    my_set_font()
  end

  # 2015-03-24
  def menu_save_font()
    File.open(MY_FONT,"w") do |fp|
      fp.puts "#{@font} #{@size}"
    end
  end

  def menu_reset_font()
    @font = 'Courier'
    @size = 14
    my_set_font()
    #    menu_save_font()
  end

  def my_set_font()
    @textarea.configure(:font=>"#{@font} #{@size}")
  end

  def menu_percentile
    @stat.percentile
  end

  def insert()
    # reset session parameters
    @line = 0
    @char = 0
    @epilog = false
    @time_remains = TIMEOUT
    @wait_for_first_key = true

    pos = rand(@text_all.length - 1.2 * @lines)
    @text = @text_all[pos, @lines]
    if (@text.join.length < 350)
      self.insert()
      return
    end

    @textarea.insert(@text.join)
    @textarea.highlight("good", @line, @char)
    @logger = Logger.new
    @num_chars = 0
    tick = 1000
    interval=tick/1000 # interval==1
    if @left_to_right
      @scale.set(0)
    else
      @scale.set(TIMEOUT)
    end
    @timer =
      TkAfter.new(tick,
                  -1,
                  proc{
                    if (@time_remains < 0 or self.finished?)
                      @timer.cancel
                    elsif (! @wait_for_first_key)
                      @time_remains -= interval
                      if @left_to_rught
                        @scale.set(@time_remains)
                      else
                        @scale.set(TIMEOUT - @time_remains)
                      end
                      @speed_meter.plot(@num_chars) if @speed_meter_status
                      @num_chars = 0
                    end}).start
  end

  # core of yatt.rb
  def key_press(kk,key)
    return if @epilog

    # hotfix 0.22.2
    # kks are differ between linux and osx.
    # when type 'alt +'  in Linux, returns two key events,
    # (64, 65513) and (21, 61).
    # in OSX, returns a single key event.
    # (1573041, 43).
    #puts "kk: #{kk}, key: #{key}"
    if (kk == 1573041 or kk == 1581664)
      menu_bigger
      return
    end
    if kk == 1777683
      menu_smaller
      return
    end
    #

    key &= 0x00ff
    return if (key==0 or key>128) # shift, control or alt. do nothing
    if @wait_for_first_key
      @wait_for_first_key = false
      @logger.start
    end
    @num_chars += 1
    if (@time_remains < 0) or (@line >= @lines) # session ends
      @logger.finish    # stop KeyPress event ASAP
      epilog
      return
    end
    c = key.chr
    case target = @text[@line][@char]
    when "\n"
      if (key == 0x0d) #match
        @logger.add_good(target)
        @textarea.unlight(@line,@char)
        @line += 1
        @char = 0
        if finished?
          @logger.finish
          @logger.complete = true
          epilog
          return
        end
        @textarea.highlight("good",@line,@char)
      else
        @logger.add_ng(target,key)
        @textarea.highlight("bad",@line,@char)
        if @textarea.value_loose
          @line += 1
          @char = 0
          @textarea.highlight("good",@line,@char)
        end
      end # when "\n"
    when c    # match
      @logger.add_good(target)
      @textarea.unlight(@line,@char)
      @char += 1
      @textarea.highlight("good",@line,@char)
    else # not match
      @logger.add_ng(target,key)
      @textarea.highlight("bad",@line,@char)
      if @textarea.value_loose
        @char += 1
        @textarea.highlight("good",@line,@char)
      end
    end
  end #key_press

  def finished?
    @line == @lines
  end

  def epilog
    @epilog = true
    while (@timer.running?)
      @timer.stop
    end
    score   = @logger.score
    strokes = @logger.goods + @logger.bads
    errors  = if @logger.goods == 0
                100.0
              else
                (((@logger.bads.to_f/@logger.goods.to_f)*1000).floor).to_f/10
              end
    msg = "#{score} points in #{@logger.diff_time} second.\n"+
          "strokes: #{strokes}\n"+
          "errors:  #{errors}%\n"
    if errors > 3.0
      msg += "\nError-rate is too high.\nYou have to achieve 3.0%.\n"
    elsif errors > 1.0 and score > 70
          msg += "\nyour error-rate < 3.0%.\nBonus 10.\n"
          score += 10
    elsif errors <= 1.0 and score > 70
          msg += "\nyour error-rate < 1.0%.\nBonus 30.\n"
          score += 30
    end
    if c = @logger.complete?
      score += 100
      msg += "+ bonus complete (100)\n"
      score += (tr = @time_remains*50)
      msg += "+ bonus time remains (#{tr})\n"
    end
    if p = @logger.perfect?
      score += 300
      msg += "+ bonus perfect (300)\n"
    end
    if (c or p)
      msg += "becomes #{score}!!!\n"
    end

    @logger.save(score)
    @logger.save_errors(errors)
    @logger.accumulate
    @stat.plot(@logger.sum_good,@logger.sum_ng)

    # 2012-06-26, 「ハイスコア達成時だけsubmitする」に戻す。
    # @logger.set_highscore(score) if score > @logger.highscore
    # @scoreboard.submit(@myid,score)
    if score > @logger.highscore
      @logger.set_highscore(score)
      @scoreboard.submit(@myid,score)
    end

    #
    @scoreboard.update if @contest
    sleep(1)
    ret = TkDialog.new(:title   => 'yet another type trainer',
                 :message => msg,
                 :buttons => 'continue').value
    insert()
    @epilog = false
  end #epilog

end #Trainer
