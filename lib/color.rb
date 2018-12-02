
# Colors are 'global' for now
Black, Blue, Cyan, Green, Magenta, Red, White, Yellow = 
  :black, :blue, :cyan, :green, :magenta, :red, :white, :yellow

Colors = [Black, Blue, Cyan, Green, Magenta, Red, White, Yellow]

class RubyText::Color
  Colors = [Black, Blue, Cyan, Green, Magenta, Red, White, Yellow]

  def self.sym2const(color)   # to curses constant
    X.const_get("COLOR_#{color.to_s.upcase}")
  end

  def self.index(color)
    Colors.find_index(color)  # "our" number
  end

  def self.pair(fg, bg)
    nf = index(fg)
    nb = index(bg)
    File.open("/tmp/pair.out", "w") do |f| 
      f.puts "fg, bg = #{[fg, bg].inspect}" 
      f.puts "Colors = #{Colors.inspect}"
      f.puts "index fg = #{nf.inspect}"
      f.puts "index bg = #{nb.inspect}"
    end
    num = 8*nf + nb
    X.init_pair(num, sym2const(fg), sym2const(bg))
    num
  end
end

class RubyText::Window
  def self.colorize!(win, fg, bg)
    File.open("/tmp/cize.out", "w") do |f|
      f.puts "colorize: fg, bg = #{[fg, bg].inspect}"
    end
    cp = RubyText::Color.pair(fg, bg)
    win.color_set(cp)
    num = win.maxx * win.maxy
    win.setpos 0,0
    win.addstr(' '*num)
    win.setpos 0,0
    win.refresh
  rescue => err
    File.open("/tmp/#{__method__}.out", "w") do |f|
      f.puts err
      f.puts err.backtrace
    end
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
    set_colors(sym, @bg)
  end

  def bg=(sym)
    set_colors(@fg, sym)
  end
end

