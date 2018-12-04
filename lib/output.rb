$LOAD_PATH << "lib"

class RubyText::Window
  def center(str)
    r, c = self.rc
    n = @cwin.maxx - str.length
    go r, n/2
    self.puts str
  end

  def putch(ch)
    r, c = self.rc
    self[r, c] = ch[0]
  end

# FIXME Please refactor the Hal out of this.

  def effect?(arg)
    arg.is_a?(RubyText::Effects)
  end

  def delegate_output(sym, *args)
    self.cwin.attrset(0)
    args = [""] if args.empty?
    args += ["\n"] if sym == :puts
    set_colors(@fg, @bg)
    debug "  set colors: #{[@fg, @bg].inspect}"
    if sym == :p
      args.map! {|x| effect?(x) ? x : x.inspect }
    else
      args.map! {|x| effect?(x) ? x : x.to_s }
    end
    args.each do |arg|  
      if arg.is_a?(RubyText::Effects)
        attr, fg = arg.value, arg.fg
        self.cwin.attron(attr)
        self.set_colors(fg, @bg) if fg
      elsif arg.respond_to? :effect
        attr, fg = arg.effect.value, arg.effect.fg
        self.cwin.attron(attr)
        self.set_colors(fg, @bg) if fg
      else
        arg.each_char {|ch| ch == "\n" ? crlf : @cwin.addch(ch) }
        @cwin.refresh
      end
    end
    crlf if sym == :p
    set_colors(@fg, @bg)
    @cwin.refresh
  end

  def puts(*args)
    delegate_output(:puts, *args)
  end

  def print(*args)
    delegate_output(:print, *args)
  end

  def p(*args)
    delegate_output(:p, *args)
  end

  def rcprint(r, c, *args)
    self.go(r, c) { self.print *args }
  end

  def rcprint!(r, c, *args)
    @cwin.setpos(r, c)  # Cursor isn't restored
    self.print *args
  end

  def crlf     # Technically not output...
    r, c = rc
    if @scrolling
      if r == @rows - 1  # bottom row
        scroll
        left!
      else
        go r+1, 0
      end
    else
      if r == @rows - 1  # bottom row
        left!
      else
        go r+1, 0
      end
    end
  end

  def self.clear(win)
    num = win.maxx * win.maxy
    win.setpos(0, 0)
    win.addstr(' '*num)
    win.setpos(0, 0)
    win.refresh
  end

  def clear
    num = @cwin.maxx * @cwin.maxy
    home
    @cwin.addstr(' '*num)
    home
    @cwin.refresh
  end

  def output(&block)
    $stdscr = self
    block.call
    $stdscr = STDSCR
  end

  def [](r, c)
    ch = nil
    go(r, c) { ch = @cwin.inch }
    debug "ch = #{ch}  ch.chr = #{ch.chr}"
    ch.chr
  end

  def []=(r, c, char)
    @cwin.setpos(r, c)
    @cwin.addch(char[0])
    @cwin.refresh
  end

  def boxme
    @outer.box(Vert, Horiz)
    @outer.refresh
  end

  def refresh
    @cwin.refresh
  end
end

# into top level...

module WindowIO
  def puts(*args)       # Doesn't affect STDOUT.puts, etc.
    $stdscr.puts(*args)
  end

  def print(*args)
    $stdscr.print(*args)
  end

  def p(*args)
    $stdscr.p(*args)
  end

  def rcprint(r, c, *args)
    $stdscr.rcprint r, c, *args
  end

  def getch
    X.getch
  end
end

