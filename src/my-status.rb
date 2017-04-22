# VERSION: 0.80

class MyStatus <TkCanvas

  WIDTH   = 420
  HEIGHT  = 200
  C_WIDTH = 10
  C_HEIGHT= 20

  def initialize(parent,splash)
    @graph = TkCanvas.new(parent,
                          :width => WIDTH,
                          :height => HEIGHT,
                          :background => 'white')
    if FileTest.exists?(splash)
      img = TkPhotoImage.new(:file=>splash)
      TkcImage.new(@graph,WIDTH/2,130,:image=>img)
    end
    @percentile = false
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
    dx = (WIDTH-2*C_WIDTH).to_f/(keys.length-1) # -1 for ' '
    max = 0
    keys.each do |key|
      next if key.chr == ' '      # do not display ' '
      n = good[key] + bad[key]
      max = n if n>max
    end
    ratio = (HEIGHT-C_HEIGHT*2).to_f/max
    ox = C_WIDTH
    oy = HEIGHT-C_HEIGHT
    half_x = dx/2
    base_y = HEIGHT-C_HEIGHT/2
    while (key = keys.shift)
      next if key.chr == ' '      # do not display ' '
      if (@percentile)
        n = good[key] + bad[key]
        rect(ox,oy,good[key].to_f*max/n,bad[key].to_f*max/n,dx,ratio)
      else
        rect(ox,oy,good[key],bad[key],dx,ratio)
      end
      text(ox+half_x,base_y,key)
      ox += dx
    end
  end

  def rect(x, y, good, bad, dx, ry)
    TkcRectangle.new(@graph, x, y, x+dx, y-good*ry, fill: GOOD)
    TkcRectangle.new(@graph, x, y-good*ry, x+dx, y-(good+bad)*ry, fill: BAD)
  end

  def text(x,y,char)
    TkcText.new(@graph, x, y, :text=>char.chr)
  end
end # Status
