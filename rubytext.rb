require 'curses'

$debug = File.new("debug.out", "w")

RTdown  = 258
RTup    = 259
RTleft  = 260
RTright = 261

RTenter = 10
RTf1    = 265
RTf2    = 266
RTf3    = 267
RTf4    = 268
RTf5    = 269
RTf6    = 270
RTf7    = 271
RTf8    = 272
RTf9    = 273
RTf10   = 274
RTf11   = 275
RTf12   = 276

###

X = Curses  # shorthand

module RubyText
  class Window
    def self.main
$debug.puts "Entering Window.main"
      main_win = X.init_screen
      rows, cols = main_win.maxy, main_win.maxx
$debug.puts "About to call .make"
      self.make(main_win, rows, cols, 0, 0, false)
    end

    def self.make(cwin, high, wide, r0, c0, border)
$debug.puts "make: #{[cwin, high, wide, r0, c0, border]}"
      obj = self.allocate
$debug.puts "Allocate returned a #{obj.class}"
      obj.instance_eval do 
$debug.puts "  Inside instance_eval..."
        @outer = @win = cwin
        @wide, @high, @r0, @c0 = wide, high, r0, c0
        @border = border
        @rows, @cols = high, wide
        @width, @height = @cols + 2, @rows + 2 if @border
      end
      obj
    end
  end
end

$debug.puts "Setting STDSCR to Window.main"

STDSCR = RubyText::Window.main
$stdscr = STDSCR

###

module RubyText

  # For passing through arbitrary method calls
  # to the lower level...

  def self.method_missing(name, *args)
$debug.puts "method_missing: #{name}  #{args.inspect}"
    if name[0] == '_'
      X.send(name[1..-1], *args)
    else
      raise NoMethodError
    end
  end

  def RubyText.window(high, wide, r0, c0, border=false)
    RubyText::Window.new(high, wide, r0, c0, border)
  end

  def self.start(*args)
    X.noecho
    X.stdscr.keypad(true)
    X.cbreak   # by default

    args.each do |arg|
      case arg
        when :raw
          X.raw
        when :echo
          X.echo
        when :noecho
          X.noecho
      end
    end
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

end

class RubyText::Window
  attr_reader :win, :rows, :cols, :width, :height

  def initialize(high=nil, wide=nil, r0=1, c0=1, border=false)
$debug.puts "RT::Win.init: #{[high, wide, r0, c0, border]}"
    @wide, @high, @r0, @c0 = wide, high, r0, c0
    @border = border
    @win = X::Window.new(high, wide, r0, c0)
$debug.puts "outer = #{@win.inspect}"
$debug.puts "@border = #@border"
    if @border
      @win.box(?|, ?-)
      @outer = @win
      @outer.refresh
$debug.puts "About to call again: params = #{[high-2, wide-2, r0+1, c0+1]}"
      @win = X::Window.new(high-2, wide-2, r0+1, c0+1)  # relative now??
    else
      @outer = @win
    end
    @rows, @cols = @win.maxy, @win.maxx  # unnecessary really...
    @width, @height = @cols + 2, @rows + 2 if @border
    @win.refresh
  end

  def puts(*args)
    args = [""] if args.empty?
$debug.puts  "args = #{args.inspect}"
    str = sprintf(*args)
    str << "\n" unless str[-1] == "\n"
    @win.addstr(str)
    @win.refresh
  end

  def print(*args)
    args = [""] if args.empty?
    str = sprintf(*args)
    @win.addstr(str)
    @win.refresh
    # X.stdscr.refresh
  end

  def p(*args)
    args = [""] if args.empty?
    strs = args.map {|x| x.inspect }
    self.puts strs
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

  def rc
    [@win.cury, @win.curx]
  end

  def clear
    @win.clear
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
    ch
#   go(r, c) { ch = @win.inch }
  end

  def []=(r, c, char)
    @win.setpos(r, c)
    @win.addstr(char[0])
  end

  def boxme
    @outer.box(?|, ?-) if @border
    @outer.refresh
  end

  def refresh
    @win.refresh
  end
end


####

### Stick stuff into Kernel for top level

module Kernel
  private 
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

####

RubyText.start   # May get replaced in client code

