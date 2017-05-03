# VERSION: 0.90

class MyText < TkText
  @@sticky = false
  @@loose  = false

  def initialize(parent, params)
    @text=TkText.new(parent,params)
    @text.tag_configure('good', background: GOOD)
    @text.tag_configure('bad',  background: BAD)
  end

  def insert(text)
    @text.configure(state: 'normal')
    @text.delete('1.0', 'end')
    @text.insert('end', text)
    @text.configure(state: 'disabled')
  end

  def pack
    @text.pack
  end

  def highlight(stat, line, char)
    pos = (line + 1).to_s + "." + char.to_s
    @text.tag_add(stat, pos)
  end

  def unlight(line, char)
    pos = (line+1).to_s + "." + char.to_s
    @text.tag_remove('good', pos)
    @text.tag_remove('bad', pos) unless @@sticky
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
    @@sticky = value
  end

  def set_loose(value)
    @@loose = value
  end

  def configure(param)
    @text.configure(param)
  end
end #MyText
