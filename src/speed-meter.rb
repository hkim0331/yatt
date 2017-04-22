# VERSION: 0.80

class SpeedMeter
  include Math

  WIDTH  = 50
  HEIGHT = 40
  MAX    = 14

  def config(stat)
    if (stat)
      plot(0)
    else
      clear
    end
  end

  def initialize(parent)
    @canvas = TkCanvas.new(parent,
                           :width => WIDTH,
                           :height => HEIGHT,
                           :takefocus => 0)
    r = (WIDTH/2) * 0.8
    pi = 3.14
    @xy = (0..MAX).map{|n| [r*cos(pi-n*pi/MAX), r*sin(pi-n*pi/MAX)]}
    @ox = WIDTH/2
    @oy = HEIGHT * 0.8
    plot(0)
  end

  def pack(params)
    @canvas.pack(params)
  end

  def clear()
    @canvas.delete('all')
  end

  # here
  def plot(n)
    clear()
    n = [n, MAX].min
    x,y = @xy[n]
    TkcLine.new(@canvas, @ox, @oy, @ox+x, @oy-y, width:2, fill: 'red')
    TkcOval.new(@canvas, @ox-2, @oy-2, @ox+2, @oy+2, fill: 'black')
  end

end # SpeedMeter
