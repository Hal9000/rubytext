$LOAD_PATH << "lib"

def debug(*args)
  return unless $debug
  $debug.puts *args
end

class RubyText::Window
  def center(str)
    r, c = self.rc
    n = @win.maxx - str.length
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

  def delegate_output(sym, *args)
    args = [""] if args.empty?
    RubyText::Window.colors(@win, @fg, @bg)  # FIXME?
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
# STDOUT.puts "again: #{args.inspect}"
    flag = need_crlf?(sym, args)
    # Limitation: Can't print color symbols!
    args.each do |arg|  
      if arg.is_a? Symbol # must be a color
        RubyText::Window.colors(@win, arg, @bg)  # FIXME?
      elsif arg.is_a? RubyText::Effects
        X.attrset(arg.value)
      else
        arg.each_char {|ch| ch == "\n" ? crlf : @win.addch(ch) }
      end
    end
    crlf if flag
    RubyText::Window.colors(@win, @fg, @bg)  # FIXME?
    @win.refresh
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
    @win.setpos(r, c)  # Cursor isn't restored
    self.print *args
  end

  def crlf
    # Technically not output...
    r, c = rc
    go r+1, 0
  end

  def self.clear(win)
    num = win.maxx * win.maxy
    win.setpos(0, 0)
    win.addstr(' '*num)
    win.setpos(0, 0)
    win.refresh
  end

  def clear
    win = @win
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
    @win.setpos r, c
    ch = @win.inch
    @win.setpos *save
    ch.chr
#   go(r, c) { ch = @win.inch }
  end

  def []=(r, c, char)
    @win.setpos(r, c)
    @win.addch(char[0])
    @win.refresh
  end

  def boxme
    @outer.box(Vert, Horiz)
    @outer.refresh
  end

  def refresh
    @win.refresh
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

