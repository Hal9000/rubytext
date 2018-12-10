$LOAD_PATH << "lib"

class RubyText::Window
  def center(str)
    r, c = self.rc
    n = @cwin.maxx - str.length
    go r, n/2
    self.puts str
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
        arg.set(self)
      elsif arg.respond_to? :effect
        arg.effect.set(self)
        arg.each_char {|ch| ch == "\n" ? crlf : @cwin.addch(ch) }
        @cwin.refresh
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
    self.go(r, c)  # Cursor isn't restored
    self.print *args
  end

  def _putch(ch)
    @cwin.addch(ch)
  end

  def putch(ch, r: nil, c: nil, fx: nil)
    debug("putch: #{[ch, r, c, fx].inspect}")
    if r.nil? && c.nil? && fx.nil?
      _putch(ch) 
    else
      r0, c0 = self.rc
      r ||= r0
      c ||= c0
      go(r, c) do
        fx.set(self) if fx
        val = fx.value rescue 0
        @cwin.addch(ch.ord|val)
        # @cwin.addch(ch)
      end
      fx.reset(self) if fx
    end
    @cwin.refresh
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
    recv = RubyText.started ? $stdscr : Kernel
    recv.puts(*args)
  end

  def print(*args)
    recv = RubyText.started ? $stdscr : Kernel
    recv.print(*args)
  end

  def p(*args)
    recv = RubyText.started ? $stdscr : Kernel
    recv.p(*args)
  end

  def rcprint(r, c, *args)
    recv = RubyText.started ? $stdscr : Kernel
    recv.rcprint r, c, *args
  end

  # FIXME These don't/can't honor @started flag...

  def getch
    X.getch
  end

  def gets  # still needs improvement
    str = ""
    loop do
      ch = ::STDSCR.getch
      if ch == 10
        ::STDSCR.crlf
        break 
      end
      str << ch
    end
    str
  end

  def putch(ch, r: nil, c: nil, fx: nil)
    r, c = STDSCR.rc
    r ||= r0
    c ||= c0
    STDSCR.putch(ch, r: r, c: c, fx: fx)
  end
end

