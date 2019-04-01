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
    meth = sym == :p ? :inspect : :to_s
    args.map! {|x| effect?(x) ? x : x.send(meth) }
    args.each do |arg|  
      if arg.is_a?(RubyText::Effects)
        arg.set(self)
      else
        arg.effect.set(self) if arg.respond_to? :effect
        arg.each_char {|ch| ch == "\n" ? crlf : @cwin.addch(ch) }
        @cwin.refresh
      end
    end
    crlf if sym == :p   # no implicit newline
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

  def self.clear(win)   # delete this?
    num = win.maxx * win.maxy
    win.setpos(0, 0)
    win.addstr(' '*num)
    win.setpos(0, 0)
    win.refresh
  end

  def clear
    self.home
    self.scroll self.rows
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
    @cwin.addch(char[0].ord|Curses::A_NORMAL)
    @cwin.setpos(r, c)
    @cwin.refresh
  end

  def boxme
    @outer.box(Vert, Horiz)
    @outer.refresh
  end

  def refresh
    @cwin.refresh
  end

  class GetString
    def initialize(win = STDSCR, str = "", i = 0, history: [], limit: nil, tab: [])
      @win = win
      @r0, @c0 = @win.rc
      @limit = limit || (@win.cols - @r0 - 1)
      raise ArgumentError unless @limit.is_a?(Numeric)
      @str, @i = str[0..(@limit-1)], i
      @str ||= ""
      @win.print @str
      @win.left @str.length
      @history = history
      @h = @history.length - 1
      @maxlen = 0    # longest string in history list
      @tabcom = tab
    end

    def enter
      @win.crlf
      @history << @str
      @h = @history.length - 1
    end

    def left_arrow
      if @i > 0
        @i -= 1
        @win.left
      end
    end

    def right_arrow
      if @i < @str.length
        @i += 1
        @win.right
      end
    end

    def backspace
      # remember: may be in middle of string
      return if @i == 0
      @i -= 1
      @str[@i] = ""
      @win.left
      @win.rcprint @r0, @c0, @str + " "
    end

    def history_prev
      return if @history.empty?
      @win.go @r0, @c0
      @maxlen = @history.map(&:length).max
      @win.print(" "*@maxlen)
      @h = (@h - 1) % @history.length
      @str = @history[@h]
      @i = @str.length
      @win.go @r0, @c0
      @win.print @str
    end

    def history_next
      return if @history.empty?
      @h = (@h + 1) % @history.length
      @win.go @r0, @c0
      @maxlen = @history.map(&:length).max
      @win.print(" "*@maxlen)
      @str = @history[@h]
      @i = @str.length
      @win.go @r0, @c0
      @win.print @str
    end

    def complete
      targets = @tabcom.find_all {|x| x.start_with?(@str) }
      if targets.nil?
        Curses.beep
        return
      end
      if targets.size > 1
        num, target = @win.menu(items: targets)
      else
        target = targets.first
      end
      @str = target.nil? ? "" : target.dup
      @i = @str.length
      @win.go @r0, @c0
      @win.print @str
    end

    def add(ch)
      if @str.length >= @limit
        Curses.beep
        return
      end
      @str.insert(@i, ch)
      @win.right
      @win.go(@r0, @c0) { @win.print @str }
      @i += 1
    end

    def value
      @str
    end
  end

  def gets(history: [], limit: nil, tab: [], default: "")  # still needs improvement
    # echo assumed to be OFF, keypad ON
    @history = history
    gs = GetString.new(self, default, history: history, limit: limit, tab: tab)
    loop do
      ch = self.getch
      case ch
        when 10
          gs.enter
          break
        when 8, 127, 63   # backspace, del, ^H (huh?)
          gs.backspace
        when 9  # tab
          gs.complete
        when 260   # left-arrow
          gs.left_arrow
        when 261   # right-arrow
          gs.right_arrow
        when 259   # up
          next if @history.nil?  # move this?
          gs.history_prev
        when 258   # down
          next if @history.nil?  # move this?
          gs.history_next
        when 27    # escape
          gs.enter
          break
        when Integer
          Curses.beep
        else
          gs.add(ch)
      end
    end
    gs.value
  rescue => err
    str = err.to_s + "\n" + err.backtrace.join("\n")
    raise str
  end

end

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
    Curses.getch
  end

  def gets  # still needs improvement
    recv = RubyText.started ? $stdscr : Kernel
    recv.gets
  end

  def putch(ch, r: nil, c: nil, fx: nil)
    r, c = STDSCR.rc
    r ||= r0
    c ||= c0
    STDSCR.putch(ch, r: r, c: c, fx: fx)
  end
end

