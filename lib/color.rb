
def fb2cp(fg, bg)
  fg ||= Blue
  bg ||= White
  f2 = X.const_get("COLOR_#{fg.upcase}")
  b2 = X.const_get("COLOR_#{bg.upcase}")
  cp = $ColorPairs[[fg, bg]]
  [f2, b2, cp]
end

# Colors are 'global' for now
Black, Blue, Cyan, Green, Magenta, Red, White, Yellow = 
  :black, :blue, :cyan, :green, :magenta, :red, :white, :yellow

class RubyText::Color
  Colors = [Black, Blue, Cyan, Green, Magenta, Red, White, Yellow]

  def self.sym2const(color)   # to curses constant
    X.const_get("COLOR_#{color.to_s.upcase}")
  end

  def self.index(color)
    Colors.find_index(color)  # "our" number
  end

  def self.pair(fg, bg)
    num = 8*index(fg) + index(bg)
    X.init_pair(num, sym2const(fg), sym2const(bg))
    num
  end
end

class RubyText::Window
  def self.colorize!(win, fg, bg)
    cp = RubyText::Color.pair(fg, bg)
    win.color_set(cp)
    num = win.maxx * win.maxy
    win.setpos 0,0
    win.addstr(' '*num)
    win.setpos 0,0
    win.refresh
  end

  def set_colors(fg, bg)
    cp = RubyText::Color.pair(fg, bg)
    @cwin.color_set(cp)
  end

  def colorize!(fg, bg)
    set_colors(fg, bg)
    num = @cwin.maxx * @cwin.maxy
    self.home
    self.go(0, 0) { @cwin.addstr(' '*num) }
    @cwin.refresh
  end

  def fg=(sym)
    set_colors(fg, @bg)
  end

  def bg=(sym)
    set_colors(@fg, bg)
  end
end

