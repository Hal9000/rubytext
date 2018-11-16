$LOAD_PATH << "lib"

require 'curses'

require 'version'   # skeleton + version

X = Curses  # shorthand

def debug(*args)
  return unless $debug
  $debug.puts *args
end

module RubyText

  Colors = %w[black blue cyan green magenta red white yellow]
  ColorPairs = {}
  num = 0
  Colors.each do |fc|
    Colors.each do |bc|
      fg = X.const_get("COLOR_#{fc.upcase}")
      bg = X.const_get("COLOR_#{bc.upcase}")
      X.init_pair(num+=1, fg, bg)  # FIXME backwards?
      ColorPairs[[fg, bg]] = num
    end
  end

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
    def self.main
      debug "Entering Window.main"
      @main_win = X.init_screen
      X.start_color
#     X.init_pair(1, X::COLOR_BLACK, X::COLOR_WHITE)
#     X.stdscr.bkgd(X.color_pair(1)|X::A_NORMAL)
      rows, cols = @main_win.maxy, @main_win.maxx
      debug "About to call .make"
      @screen = self.make(@main_win, rows, cols, 0, 0, false, "white", "black")
      @screen
    end

    def self.make(cwin, high, wide, r0, c0, border, fg, bg)
      debug "make: #{[cwin, high, wide, r0, c0, border, fg, bg]}"
      obj = self.allocate
      debug "Allocate returned a #{obj.class}"
      obj.instance_eval do 
        debug "  Inside instance_eval..."
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

# debug "Setting STDSCR to Window.main"

STDSCR = RubyText::Window.main
$stdscr = STDSCR

###

module RubyText

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

  def RubyText.window(high, wide, r0, c0, border=false, fg="white", bg="black")
    RubyText::Window.new(high, wide, r0, c0, border, fg, bg)
  end

  def self.start(*args, log: nil, fg: nil, bg: nil)
    $debug = File.new(log, "w") if log
    fg ||= :white
    bg ||= :black
    debug "fg = #{fg} is not a valid color" unless Colors.include?(fg.to_s)
    debug "bg = #{bg} is not a valid color" unless Colors.include?(bg.to_s)
debug "Colors are: #{fg} on #{bg}"
    fg = X.const_get("COLOR_#{fg.upcase}")
    bg = X.const_get("COLOR_#{bg.upcase}")
debug "Curses colors are: #{fg} on #{bg}"
    cp = ColorPairs[[fg, bg]]
debug "cp is: #{cp}"
    X.stdscr.bkgd(cp|X::A_NORMAL)
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
        when :color
          X.start_color
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
  Vert, Horiz = X::A_VERTICAL, X::A_HORIZONTAL  # ?|, ?-    # "\u2502", "\u2500"

  attr_reader :win, :rows, :cols, :width, :height, :fg, :bg

  def initialize(high=nil, wide=nil, r0=1, c0=1, border=false, fg=:white, bg=:black)
    debug "RT::Win.init: #{[high, wide, r0, c0, border]}"
    @wide, @high, @r0, @c0 = wide, high, r0, c0
    @border = border
    @fg, @bg = fg, bg
    @win = X::Window.new(high, wide, r0, c0)
    debug "outer = #{@win.inspect}"
    debug "@border = #@border"
    if @border
      @win.box(Vert, Horiz)
      @outer = @win
      @outer.refresh
      debug "About to call again: params = #{[high-2, wide-2, r0+1, c0+1]}"
      @win = X::Window.new(high-2, wide-2, r0+1, c0+1) # , false, fg, bg)  # relative now??
    else
      @outer = @win
    end
    @rows, @cols = @win.maxy, @win.maxx  # unnecessary really...
    @width, @height = @cols + 2, @rows + 2 if @border
    @win.refresh
  end

  def delegate_output(sym, *args)
    args = [""] if args.empty?
#   debug "#{sym}: args = #{args.inspect}"
    if sym == :p
      args.map!(&:inspect) 
    else
      args.map!(&:to_s) 
    end
    str = sprintf(*args)
    str << "\n" if sym != :print && str[-1] != "\n"
    # color-handling code here
    @win.addstr(str)
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

  def down
    r, c = rc
    go r+1, c
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
  # private 
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

