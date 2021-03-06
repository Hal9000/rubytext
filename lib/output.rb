$LOAD_PATH << "lib"

require 'keys'

class RubyText::Window
  include ::RubyText::Keys

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
    num = win.maxx * win.maxy - 1
    win.setpos(0, 0)
    win.addstr(' '*num)
    win.setpos(0, 0)
    win.refresh
  end

  def clear
    cwin.setpos(cwin.maxx, cwin.maxy)
    cwin.addstr(' ')
    num = cwin.maxx * cwin.maxy - 1
    cwin.addstr(' '*num)
    cwin.setpos(0, 0)
    cwin.refresh
  end

  def output(&block)
    $stdscr = self
    block.call
    $stdscr = STDSCR
  end

=begin
  def go(r0, c0)
    r, c = coords(r0, c0)
    save = self.rc
    goto r, c 
    if block_given?
      yield 
      goto *save
    end
  end
=end

  def [](r, c)
    r0, c0 = self.rc
    @cwin.setpos(r, c)
    ch = @cwin.inch
    @cwin.setpos(r0, c0)
    ch.chr
  end

  def []=(r, c, char)
    r0, c0 = self.rc
    @cwin.setpos(r, c)
    @cwin.addch(char[0].ord|Curses::A_NORMAL)
    @cwin.setpos(r0, c0)
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
    def initialize(win = STDSCR, str = "", i = 0, history: [], limit: nil, tab: [], capture: [])
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
        # Curses.beep
        @win.print "???"
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

  def gets(history: [], limit: nil, tab: [], default: "", capture: [])
    # needs improvement
    # echo assumed to be OFF, keypad ON
    @history = history
    gs = GetString.new(self, default, history: history, limit: limit, tab: tab, 
                       capture: capture)
    count = 0
    loop do
      count += 1      # Escape and 'capture' chars have special meaning if first char
      ch = self.getch
      case ch
        when *capture 
          return ch if count == 1
          gs.add(ch)
        when Escape
          return Escape if count == 1
          gs.enter
          break
        when CtlD
          return CtlD if count == 1
          gs.enter
          break
        when Enter
          gs.enter
          break
        when BS, DEL, 63   # backspace, del, ^H (huh?)
          gs.backspace
        when Tab
          gs.complete
        when Left
          gs.left_arrow
        when Right
          gs.right_arrow
        when Up
          next if @history.nil?  # move this?
          gs.history_prev
        when Down
          next if @history.nil?  # move this?
          gs.history_next
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

