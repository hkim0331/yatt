# VERSION: 0.70
class MyPlot
  WIDTH  = 300
  HEIGHT = 200
  SHRINK = 0.86
  MX = 30
  MY = 10
  R  = 5

  def initialize(title)
    @toplevel = TkToplevel.new(:title => title)
    @graph = TkCanvas.new(@toplevel,
                        :width => WIDTH,
                        :height => HEIGHT)
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
    lst = lst.map {|y| (HEIGHT-MY)-y*ratio}
    x = MX
    while (y = lst.shift)
      TkcOval.new(@graph,x,y,x+R,y-R,:outline => 'red',:fill => 'red')
      x+=dx
    end
  end

  def x_axes(max)
    TkcLine.new(@graph,MX,HEIGHT-MY,max,HEIGHT-MY)
  end

  def y_axes(max,ratio)
    TkcLine.new(@graph,MX,HEIGHT-MY,MX,MY)
    TkcText.new(@graph,MX/2,HEIGHT-max*ratio,:text => max.to_s)
    TkcText.new(@graph,MX/2,HEIGHT-MY, :text => '0')
  end

  def clear
    @graph.delete("all")
  end

  def replot(lst)
    clear
    plot(lst)
  end
end
