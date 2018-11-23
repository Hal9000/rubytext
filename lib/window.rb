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

  def self.wocka
    STDSCR.puts "HELLO!!!!!!"
    sleep 5
  end
end

