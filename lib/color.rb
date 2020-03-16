
# Colors are 'global' for now
Black, Blue, Cyan, Green, Magenta, Red, White, Yellow = 
  :black, :blue, :cyan, :green, :magenta, :red, :white, :yellow

Colors = [Black, Blue, Cyan, Green, Magenta, Red, White, Yellow]

# Handles color constants and fg/bg pairs

class RubyText::Color

  Colors = ::Colors

# FIXME some should be private
# TODO  add color-pair constants

  # Convert Ruby symbol to curses color constant name

  def self.sym2const(color)   # to curses constant
    Curses.const_get("COLOR_#{color.to_s.upcase}")
  end

  # Find "our" color number

  def self.index(color)
    Colors.find_index(color)  # "our" number
  end

  # Define a fg/bg color pair

  def self.pair(fg, bg)
    nf, nb = index(fg), index(bg)
    num = 8*nf + nb
    Curses.init_pair(num, sym2const(fg), sym2const(bg))
    num
  end
end

# Reopening: Wrapper for curses windows

class RubyText::Window

  # Set up a window with fg/bg

  def self.colorize!(cwin, fg, bg)
    cp = RubyText::Color.pair(fg, bg)
    cwin.color_set(cp)
    num = cwin.maxx * cwin.maxy
    cwin.setpos 0,0
    cwin.addstr(' '*num)
    cwin.setpos 0,0
    cwin.refresh
  rescue => err
    File.open("/tmp/#{__method__}.out", "w") do |f|
      f.puts err
      f.puts err.backtrace
    end
  end

  # Assign color pair to curses window

  def set_colors(fg, bg)
    cp = RubyText::Color.pair(fg, bg)
    @cwin.color_set(cp)
  end

  # Set up a window with fg/bg

  def colorize!(fg, bg)
    set_colors(fg, bg)
    num = @cwin.maxx * @cwin.maxy
    self.home
    self.go(0, 0) { @cwin.addstr(' '*num) }
    @cwin.refresh
  end

  # Set foreground color

  def fg=(sym)
    set_colors(sym, @bg)
  end

  # Set background color

  def bg=(sym)
    set_colors(@fg, sym)
  end
end

