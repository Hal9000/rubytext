$LOAD_PATH << "lib"

require 'curses'
require 'version'   # skeleton + version

X = Curses  # shorthand

require 'output'
require 'keys'
require 'menu'


class RubyText::Window
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

end
