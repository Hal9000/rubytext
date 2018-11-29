
def fb2cp(fg, bg)
  fg ||= Blue
  bg ||= White
  f2 = X.const_get("COLOR_#{fg.upcase}")
  b2 = X.const_get("COLOR_#{bg.upcase}")
  cp = $ColorPairs[[fg, bg]]
  [f2, b2, cp]
end

module RubyText
  Colors = [Black, Blue, Cyan, Green, Magenta, Red, White, Yellow]
  $ColorPairs = {}
  num = 0
  Colors.each do |fsym|
    Colors.each do |bsym|
      fg = X.const_get("COLOR_#{fsym.upcase}")
      bg = X.const_get("COLOR_#{bsym.upcase}")
      X.init_pair(num+=1, fg, bg)  # FIXME backwards?
      $ColorPairs[[fsym, bsym]] = num
    end
  end
end

class RubyText::Window
  def self.colors(win, fg, bg)
    cfg, cbg, cp = fb2cp(fg, bg)
    X.init_pair(cp, cfg, cbg)
    win.color_set(cp)
  end

  def self.colors!(win, fg, bg)
    colors(win, fg, bg)
    num = win.maxx * win.maxy
    win.setpos(0, 0)
    win.addstr(' '*num)
    win.setpos(0, 0)
    win.refresh
  end

  def fg=(sym)
    self.colors(@cwin, fg, @bg)
  end
end
