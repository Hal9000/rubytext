$LOAD_PATH << "lib"

# require 'global'  # FIXME later

class RubyText::Window
  def center(str)
    r, c = self.rc
    n = @cwin.maxx - str.length
    go r, n/2
    puts str
  end

  def putch(ch)
    r, c = self.rc
    self[r, c] = ch[0]
  end

  def need_crlf?(sym, args)
    sym != :print &&      # print doesn't default to crlf
    args[-1][-1] != "\n"  # last char is a literal linefeed
  end

# FIXME Please refactor the Hal out of this.

  def delegate_output(sym, *args)
    args = [""] if args.empty?
    RubyText::Window.colors(@cwin, @fg, @bg)  # FIXME?
    if sym == :p
      args.map!(&:inspect) 
    else
      args.map! do |x|
        if RubyText::Colors.include?(x) || x.is_a?(RubyText::Effects)
          x
        else
          x.to_s
        end
      end
    end
    flag = need_crlf?(sym, args)   # Limitation: Can't print color symbols!
    args.each do |arg|  
      if arg.is_a? Symbol # must be a color
        RubyText::Window.colors(@cwin, arg, @bg)  # FIXME?
      elsif arg.is_a? RubyText::Effects
        X.attrset(arg.value)
      else
        arg.each_char do |ch| 
          if ch == "\n" 
            crlf 
          else
            @cwin.addch(ch)
          end
        end
      end
    end
    crlf if flag
    RubyText::Window.colors(@cwin, @fg, @bg)  # FIXME?
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
    win = @cwin
    num = win.maxx * win.maxy
    win.setpos(0, 0)
    win.addstr(' '*num)
    win.setpos(0, 0)
    win.refresh
  end

  def output(&block)
    $stdscr = self
    block.call
    $stdscr = STDSCR
  end

  def [](r, c)
    save = self.rc
    @cwin.setpos r, c
    ch = @cwin.inch
    @cwin.setpos *save
    ch.chr
#   go(r, c) { ch = @cwin.inch }
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

### Stick stuff into Kernel for top level

module Kernel
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

