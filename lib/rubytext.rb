$LOAD_PATH << "lib"

require 'curses'
require 'version'   # skeleton + version

X = Curses  # shorthand

def debug(*args)
  return unless $debug
  $debug.puts *args
end

def fb2cp(fg, bg)
  fg ||= :blue
  bg ||= :white
  f2 = X.const_get("COLOR_#{fg.upcase}")
  b2 = X.const_get("COLOR_#{bg.upcase}")
  cp = $ColorPairs[[fg, bg]]
  [f2, b2, cp]
end

module RubyText

  Colors = [:black, :blue, :cyan, :green, :magenta, :red, :white, :yellow]
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

# $ColorPairs.each_pair {|k, v| STDOUT.puts "#{k.inspect} => #{v}" }

  module Keys
    Down  = 258
    Up    = 259
    Left  = 260
    Right = 261
    Enter = 10
    F1    = 265
    F2    = 266
    F3    = 267
    F4    = 268
    F5    = 269
    F6    = 270
    F7    = 271
    F8    = 272
    F9    = 273
    F10   = 274
    F11   = 275
    F12   = 276
  end

  class Window
    attr_reader :fg, :bg

    def self.colors(win, fg, bg)
      cfg, cbg, cp = fb2cp(fg, bg)
      X.init_pair(cp, cfg, cbg)
      win.color_set(cp|X::A_NORMAL)
    end

    def self.colors!(win, fg, bg)
      colors(win, fg, bg)
      num = win.maxx * win.maxy
      win.setpos(0, 0)
      win.addstr(' '*num)
      win.setpos(0, 0)
      win.refresh
    end

    def self.main(fg: nil, bg: nil)
      @main_win = X.init_screen
      X.start_color
      colors!(@main_win, fg, bg)
      rows, cols = @main_win.maxy, @main_win.maxx
      @screen = self.make(@main_win, rows, cols, 0, 0, false,
                          fg: fg, bg: bg)
# FIXME Why is this hard to inline?
#     @win = @main_win
#     obj = self.allocate
#     obj.instance_eval do 
#       @outer = @win = @main_win
#       @wide, @high, @r0, @c0 = cols, rows, 0, 0
#       @fg, @bg = fg, bg
#       @border = false
#       @rows, @cols = @high, @wide
#       @width, @height = @cols + 2, @rows + 2 if @border
#     end
#     @win = @main_win  # FIXME?
#     obj
      @screen
    end

    def self.make(cwin, high, wide, r0, c0, border, fg: :white, bg: :black)
      obj = self.allocate
      obj.instance_eval do 
        debug "  Inside instance_eval..."
        @outer = @win = cwin
        @wide, @high, @r0, @c0 = wide, high, r0, c0
        @fg, @bg = fg, bg
        @border = border
        @rows, @cols = high, wide
        @width, @height = @cols + 2, @rows + 2 if @border
      end
      obj
    end

    def fg=(sym)
      self.colors(@win, fg, @bg)
    end
  end
end


module RubyText

  def self.set(*args)
    # Allow a block?
    standard = [:cbreak, :raw, :echo, :keypad]
    @flags = []   # FIXME can set/reset individually. hmmm
    args.each do |arg|
      if standard.include? arg
        flag = arg.to_s
        @flags << arg
        flag.sub!(/_/, "no")
        X.send(flag)
      else
        @flags << arg
        case arg
          when :cursor
            X.show_cursor
          when :_cursor, :nocursor
            X.hide_cursor
        end
      end
    end
  end

  def save_flags
    @fstack ||= []
    @fstack.push @flags
  end

  def rest_flags
    @flags = @fstack.pop
  end

  def self.start(*args, log: nil, fg: nil, bg: nil)
    $debug = File.new(log, "w") if log
    Object.const_set(:STDSCR, RubyText::Window.main(fg: fg, bg: bg))
    $stdscr = STDSCR
    fg, bg, cp = fb2cp(fg, bg)
    self.set(:_echo, :cbreak, :raw)  # defaults
#   X.stdscr.keypad(true)
    self.set(*args)  # override defaults
  end

  # For passing through arbitrary method calls
  # to the lower level...

  def self.method_missing(name, *args)
    debug "method_missing: #{name}  #{args.inspect}"
    if name[0] == '_'
      X.send(name[1..-1], *args)
    else
      raise "#{name} #{args.inspect}" # NoMethodError
    end
  end

  def RubyText.window(high, wide, r0, c0, border=false, fg: nil, bg: nil)
    RubyText::Window.new(high, wide, r0, c0, border, fg, bg)
  end

  def self.hide_cursor
    X.curs_set(0)
  end

  def self.show_cursor
    X.curs_set(1)
  end

  def self.show_cursor!
    X.curs_set(2)  # Doesn't work?
  end

  def self.saveback(high, wide, r, c)
    @pos = STDSCR.rc
    @save = []
    0.upto(high) do |h|
      0.upto(wide) do |w|
        @save << STDSCR[h+r, w+c]
      end
    end
  end

  def self.restback(high, wide, r, c)
    0.upto(high) do |h|
      0.upto(wide) do |w|
        STDSCR[h+r, w+c] = @save.shift
      end
    end
    STDSCR.go *@pos
    STDSCR.refresh
  end

  def self.menu(r: 0, c: 0, items:)
    high = items.size + 2
    wide = items.map(&:length).max + 2
    saveback(high, wide, r, c)
    @mywin = RubyText.window(high, wide, r, c, true, fg: :white, bg: :blue)
    RubyText.set(:raw)
    X.stdscr.keypad(true)
    RubyText.hide_cursor
    sel = 0
    max = items.size - 1
    loop do
      items.each.with_index do |item, row|
        @mywin.go row, 0
        color = sel == row ? :yellow : :white
        @mywin.puts color, " #{item} "
      end
      ch = getch
      case ch
        when X::KEY_UP
          sel -= 1 if sel > 0
        when X::KEY_DOWN
          sel += 1 if sel < max
        when 27
          restback(high, wide, r, c)
          return nil
        when 10
          restback(high, wide, r, c)
          return sel
      end
    end
  end

end

class RubyText::Window
  Vert, Horiz = X::A_VERTICAL, X::A_HORIZONTAL

  attr_reader :win, :rows, :cols, :width, :height
  attr_writer :fg, :bg

  def initialize(high=nil, wide=nil, r0=1, c0=1, border=false, fg=nil, bg=nil)
    debug "RT::Win.init: #{[high, wide, r0, c0, border]}"
    @wide, @high, @r0, @c0 = wide, high, r0, c0
    @border, @fg, @bg      = border, fg, bg
    @win = X::Window.new(high, wide, r0, c0)
    debug "outer = #{@win.inspect}"
    debug "@border = #@border"
    debug "Calling 'colors': #{[@win, fg, bg]}"
    RubyText::Window.colors!(@win, fg, bg)
#   self.clear(@main_win)
    if @border
      @win.box(Vert, Horiz)
      @outer = @win
      @outer.refresh
      debug "About to call again: params = #{[high-2, wide-2, r0+1, c0+1]}"
      @win = X::Window.new(high-2, wide-2, r0+1, c0+1) # , false, fg, bg)  # relative now??
      RubyText::Window.colors!(@win, fg, bg)
    else
      @outer = @win
    end
    @rows, @cols = @win.maxy, @win.maxx  # unnecessary really...
    @width, @height = @cols + 2, @rows + 2 if @border
    @win.refresh
  end

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
        if RubyText::Colors.include? x
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

  def go(r, c)
    save = self.rc
    @win.setpos(r, c)
    if block_given?
      yield
      go(*save)   # No block here!
    end
  end

  def up(n=1)
    r, c = rc
    go r-n, c
  end

  def down(n=1)
    r, c = rc
    go r+n, c
  end

  def left(n=1)
    r, c = rc
    go r, c-n
  end

  def right(n=1)
    r, c = rc
    go r, c+n
  end

  def top
    r, c = rc
    go 0, c
  end

  def bottom 
    r, c = rc
    rmax = self.rows - 1
    go rmax, c
  end

  def up!
    top
  end

  def down!
    bottom
  end

  def left!
    r, c = rc
    go r, 0
  end

  def right!
    r, c = rc
    cmax = self.cols - 1
    go r, cmax
  end

  def home
    go 0, 0
  end

  def crlf
    r, c = rc
    go r+1, 0
  end

  def rc
    [@win.cury, @win.curx]
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


####

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

