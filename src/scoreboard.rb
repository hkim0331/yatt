# coding: utf-8
# VERSION: 0.78

class Scoreboard

  WIDTH  = 30
  HEIGHT = 10
  GLOBAL = :global
  WEEKLY = :weekly
  MYCLASS= :myclass

  def initialize(parent, druby, stat)
    @mode = WEEKLY
    @text = TkText.new(parent,
                     :takefocus => 0,
                     :background => 'gray',
                     :width => WIDTH,
                     :height => HEIGHT,
                     :state => 'disabled')
    @stat = stat
    @scr = TkScrollbar.new(parent)
    @text.yscrollbar(@scr)
    highlight("highlight")
    @druby = druby
    @my_id = ENV['USER']

    DRb.start_service
    @remote = DRbObject.new(nil, @druby)

    if @remote.ping =~ /ok/
      debug "druby ok"
    else
      can_not_talk(@druby)
    end

  rescue
    can_not_talk(@druby)
    @remote = nil
  end

  def global
    @mode = GLOBAL
  end

  def weekly
    @mode = WEEKLY
  end

  def myclass
    @mode = MYCLASS
  end

  def can_not_talk(druby)
    TkDialog.new(:title   => "can not talk to #{druby}",
                 :message => "サーバと通信できません。
下の continue を押し、
次に出てくる OK ボタンを押せば yatt の練習はできますが
コンテストには参加できません。
しばらく秘密練習に励んでください。",
                 :buttons => ['continue'])
  end

  def pack(param)
    @scr.pack(:side=>'left', :fill=>'y')
    @text.pack(param)
  end

  def destroy
    @remote = nil unless @remote.nil?
  end

  def highlight(color)
    @text.tag_configure("highlight",
                        :background=>"red",:foreground=>"white")
  end

  def remove(user)
    (@remote.remove(user) and self.update) unless @remote.nil?
  end

  def splash
    @text.configure(:state => 'normal')
    @text.delete('1.0','end')
    @text.insert('end',
                 "= Realtime Typing Contest =\n\n"+
                 "To join the realtime contest,\n"+
                 "choose contest from Misc menu.\n\n"+
                 " +10 if error rate < 3.0%,\n"+
                 " +30 if error rate < 1.0%,\n"+
                 " +100 if complete, and \n"+
                 " +300 if perfect.\n\n" +
                 " For bonus poins, you have to get\n"+
                 " 70pt at least."
                 )
    @text.configure(:state => 'disabled')
  end

  # changed: rankers is an array. [[hkim, [65, "2012-04-02"]]]
  def display(rankers)
    debug "#{__method__}: rankers=#{rankers}"
    if (rankers.empty?)
      debug "rankers emty."
      @text.configure(:state => 'normal')
      @text.delete('1.0','end')
      @text.insert('end',"no entry.")
      @text.configure(:state => 'disabled')
    else
      line = 1
      my_entry = 0
      ranking = ""
      rankers.each do |data|
        ranker,point_date = data
        point,date = point_date
        ranking << "%2s" % line + "%5s" % point + " " +"%-10s" % ranker +
        "%5s" % date + "\n"
        my_entry=line if @my_id =~ /#{ranker}/
        line += 1
      end
      @text.configure(:state => 'normal')
      @text.delete('1.0','end')
      @text.insert('end',ranking)

      # hilight his/her entry
      unless my_entry == 0
        @text.tag_add("highlight","#{my_entry}.0","#{my_entry}.end")
      end
      @text.configure(:state => 'disabled')
    end
  end

  def bgcolor(color)
    @text.configure(:state => 'normal')
    @text.configure(:background => color)
    @text.configure(:state => 'disabled')
  end

  # 3種類の update を作る。
  # FIXME こんなのひどい。2015-04-23
  def update
    return if @remote.nil?
    case @mode
    when WEEKLY
      display(@remote.get(RANKER))
    when GLOBAL
      display(@remote.get_global(RANKER))
    when MYCLASS
      display(@remote.get_myclass(RANKER, @my_id))
    end
  end

  # was 'rank'
  def status(user, trials)
    return if (@remote.nil?)
    if (ans = @remote.status(user))
      counts, points = trials
      TkDialog.new(:title => user,
                   :message =>
                   "#{ans}\ntotal #{counts} trials, #{points} points",
                   :buttons => ['continue'])
    else
      self.can_not_talk(@druby)
    end
  end

  # 2003.06.30,
  # changed 2012-04-21,
  def submit(myid, score)
    debug "#{__method__}: #{myid}, #{score}"
    if @remote
       @remote.put(myid,score,Time.now.strftime("%m/%d %H:%M"))
     end
  end

  def toggle_contest(uid)
    return false if @remote.nil?
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
    display(@remote.all) unless @remote.nil?
  end

end # Scoreboard

