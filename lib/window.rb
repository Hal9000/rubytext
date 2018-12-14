class RubyText::Window
  Vert, Horiz = X::A_VERTICAL, X::A_HORIZONTAL

  attr_reader :cwin, :rows, :cols, :width, :height, :scrolling
  attr_reader :r0, :c0
  attr_accessor :fg, :bg

  # Better to use Window.window IRL

  def initialize(high=nil, wide=nil, r0=1, c0=1, border=false, 
                 fg=White, bg=Blue, scroll=false)
    @wide, @high, @r0, @c0 = wide, high, r0, c0
    @border, @fg, @bg      = border, fg, bg
    @cwin = X::Window.new(high, wide, r0, c0)
    colorize!(fg, bg)
    if @border
      @cwin.box(Vert, Horiz)
      @outer = @cwin
      @outer.refresh
      @cwin = X::Window.new(high-2, wide-2, r0+1, c0+1)
      colorize!(fg, bg)
    else
      @outer = @cwin
    end
    @rows, @cols = @cwin.maxy, @cwin.maxx  # unnecessary really...
    @width, @height = @cols + 2, @rows + 2 if @border
    @scrolling = scroll
    @cwin.scrollok(scroll) 
    @cwin.refresh
  end

  def self.main(fg: White, bg: Blue, scroll: false)
    debug "Starting #main..."
    main_win = X.init_screen
    X.start_color
    self.colorize!(main_win, fg, bg)
    rows, cols = main_win.maxy, main_win.maxx
    win = self.make(main_win, rows, cols, 0, 0, border: false,
              fg: fg, bg: bg, scroll: scroll)
    debug "...started #main"
    win
  rescue => err
    File.open("/tmp/main.out", "w") {|f| f.puts err.inspect; f.puts err.backtrace } 
  end

  def self.make(cwin, high, wide, r0, c0, border: true, fg: White, bg: Black, scroll: false)
    obj = self.allocate
    obj.instance_eval do 
      @outer = @cwin = cwin
      @wide, @high, @r0, @c0 = wide, high, r0, c0
      @fg, @bg = fg, bg
      @border = border
      @rows, @cols = high, wide
      @width, @height = @cols + 2, @rows + 2 if @border
    end
    obj.scrolling(scroll)
    obj
  end

  # FIXME refactor bad code

  def scrolling(flag=true)
    @scrolling = flag
    @cwin.scrollok(flag)
  end

  def noscroll
    @scrolling = false
    @cwin.scrollok(false)
  end

  def scroll(n=1)
    if n < 0
      @cwin.scrl(n)
      (-n).times {|i| rcprint i, 0, (' '*@cols) }
    else
      n.times do |i|
        @cwin.scroll
        scrolling(false)
        rcprint @rows-1, 0, (' '*@cols)
        scrolling
      end
    end
    @cwin.refresh
  end

  def screen_text(file = nil)
    lines = []
    0.upto(self.rows-1) do |r|
      line = ""
      0.upto(self.cols-1) do |c|
        line << self[r, c]
      end
      lines << line
    end
    File.open(file, "w") {|f| f.puts lines }  if file
    lines
  end

  def saveback(high, wide, r, c)
    debug "saveback: #{[high, wide, r, c].inspect}"
    @pos = self.rc
    @save = []
    0.upto(high-1) do |h|
      0.upto(wide-1) do |w|
        @save << self[h+r-1, w+c-1]
      end
    end
  end

  def restback(high, wide, r, c)
    0.upto(high-1) do |h|
      line = ""
      0.upto(wide-1) {|w| line << @save.shift }
      self.go h+r-1, c-1
      self.print line
    end
    self.go *@pos
    @cwin.refresh
  end

  def fg=(sym)
    set_colors(fg, @bg)
  end

  def bg=(sym)
    set_colors(@fg, bg)
  end
end
