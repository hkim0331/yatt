class Logger
  attr_reader :good, :ng, :start_time, :finish_time, :complete
  attr_writer :complete

  @@sum_good  = Hash.new(0)
  @@sum_ng    = Hash.new(0)
  @@highscore = 0

  def sum_good
    @@sum_good
  end

  def sum_ng
    @@sum_ng
  end

  def initialize
    @good = Hash.new(0)
    @ng   = Hash.new(0)
  end

  def start
    @start_time = Time.now
    @complete   = false
  end

  def finish
    @finish_time = Time.now
  end

  def add_ng(target,key)
    @ng[target] += 1
  end

  def add_good(target)
    @good[target] += 1
  end

  def diff_time
    ((@finish_time-@start_time)*10).to_i/10.0
  end

  def complete?
    @complete
  end

  def perfect?
    @complete && (@ng.values.inject(:+)==0)
  end

  # this is yatt score.
  def score
    w = 0.3
    time = diff_time()
    sum_goods = goods()
    sum_bads  = bads()
    total = sum_goods + sum_bads
    (w * sum_goods * (sum_goods/total.to_f)**3 * (total/time)).floor
  end

  def highscore
    @@highscore
  end

  def set_highscore(score)
    @@highscore = score
    save_highscore(score)
  end

  def clear_highscore
    @@highscore = 0
  end

  def goods
    @good.values.sum
  end

  def bads
    @ng.values.sum
  end

  def accumulate
    @good.each do |key,value|
      @@sum_good[key] += value
    end
    @ng.each do |key,value|
      @@sum_ng[key] += value
    end
  end

  # 2015-03-24
  def save_errors(errors)
    File.open(ACCURACY, "a") do |fp|
      fp.puts "#{errors}\t#{Time.now}"
    end
  end

  def save(score)
    File.open(TODAYS_SCORE, "a") do |fp|
      fp.puts(score)
    end
  end

  def save_highscore(score)
    File.open(HISTORY,"a") do |fp|
      fp.puts "#{@@highscore}\t#{Time.now}"
    end
  end

  def save_and_quit(file)
    File.open(file,"a+") do |fp|
      fp.puts @@highscore.to_s+"\t"+Time.now.asctime
    end
  end
end #Logger
