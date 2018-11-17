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
  debug "Colors are: #{fg} on #{bg}"
  fg = X.const_get("COLOR_#{fg.upcase}")
  bg = X.const_get("COLOR_#{bg.upcase}")
  debug "Curses colors are: #{fg} on #{bg}"
  cp = $ColorPairs[[fg, bg]]
  debug "cp is: #{cp}"
  [fg, bg, cp]
end

module RubyText

  Colors = %w[black blue cyan green magenta red white yellow]
  $ColorPairs = {}
  num = 0
  Colors.each do |fc|
    Colors.each do |bc|
      fg = X.const_get("COLOR_#{fc.upcase}")
      bg = X.const_get("COLOR_#{bc.upcase}")
      X.init_pair(num+=1, fg, bg)  # FIXME backwards?
      $ColorPairs[[fg, bg]] = num
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

    def self.colors(win, fg, bg)
      cfg, cbg, cp = fb2cp(fg, bg)
      X.init_pair(cp, cfg, cbg)
      win.color_set(cp|X::A_NORMAL)
    end

    def self.main(fg: nil, bg: nil)
      debug "Entering Window.main (#{fg}, #{bg}) => "
      @main_win = X.init_screen
      X.start_color
      colors(@main_win, fg, bg)
      # FIXME clear??
      debug "About to call .make"
      rows, cols = @main_win.maxy, @main_win.maxx
      @screen = self.make(@main_win, rows, cols, 0, 0, false)
      @screen
    end

    def self.make(cwin, high, wide, r0, c0, border)
      debug "make: #{[cwin, high, wide, r0, c0, border]}"
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

# STDSCR = RubyText::Window.main
# $stdscr = STDSCR

=begin
  Logic flow - 
    main
      initscreen
      start_color
      make
    STDSCR = RubyText::Window.main
    $stdscr = STDSCR

=end

###

module RubyText

  def self.start(*args, log: nil, fg: nil, bg: nil)
    $debug = File.new(log, "w") if log
    Object.const_set(:STDSCR, RubyText::Window.main(fg: fg, bg: bg))
    $stdscr = STDSCR

    debug "fg = #{fg} is not a valid color" unless Colors.include?(fg.to_s)
    debug "bg = #{bg} is not a valid color" unless Colors.include?(bg.to_s)
    fg, bg, cp = fb2cp(fg, bg)
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

end

class RubyText::Window
  Vert, Horiz = X::A_VERTICAL, X::A_HORIZONTAL

  attr_reader :win, :rows, :cols, :width, :height, :fg, :bg

  def initialize(high=nil, wide=nil, r0=1, c0=1, border=false, fg=nil, bg=nil)
    debug "RT::Win.init: #{[high, wide, r0, c0, border]}"
    @wide, @high, @r0, @c0 = wide, high, r0, c0
    @border, @fg, @bg      = border, fg, bg
    @win = X::Window.new(high, wide, r0, c0)
    debug "outer = #{@win.inspect}"
    debug "@border = #@border"
    debug "Calling 'colors': #{[@win, fg, bg]}"
    RubyText::Window.colors(@win, fg, bg)
    self.clear
    if @border
      @win.box(Vert, Horiz)
      @outer = @win
      @outer.refresh
      debug "About to call again: params = #{[high-2, wide-2, r0+1, c0+1]}"
      @win = X::Window.new(high-2, wide-2, r0+1, c0+1) # , false, fg, bg)  # relative now??
      RubyText::Window.colors(@win, fg, bg)
    else
      @outer = @win
    end
    @rows, @cols = @win.maxy, @win.maxx  # unnecessary really...
    @width, @height = @cols + 2, @rows + 2 if @border
    @win.refresh
  end

  def delegate_output(sym, *args)
    args = [""] if args.empty?
    RubyText::Window.colors(@win, fg, bg)  # FIXME?
#   debug "#{sym}: args = #{args.inspect}"
    if sym == :p
      args.map!(&:inspect) 
    else
      args.map!(&:to_s) 
    end
    str = sprintf(*args)
    flag = true if sym != :print && str[-1] != "\n"
    # color-handling code here
    str.each_char do |ch|
      ch == "\n" ? crlf : @win.addch(ch)
    end
#   @win.addstr(str)
    crlf if flag
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

  def crlf
    r, c = rc
    go r+1, 0
  end

  def rc
    [@win.cury, @win.curx]
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

