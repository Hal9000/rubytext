
module RubyText
  def self.window(high, wide, r: nil, c: nil, border: true, 
                  fg: White, bg: Blue, scroll: false, title: nil)
    r ||= (STDSCR.rows - high)/2
    c ||= (STDSCR.cols - wide)/2
    win = RubyText::Window.new(high, wide, r, c, border, fg, bg, scroll)
    win.add_title(title) if title
    0.upto(high) {|row| 0.upto(wide) {|col| win[row, col] = " " } }
    win
  end
end

class RubyText::Window
  Vert, Horiz = Curses::A_VERTICAL, Curses::A_HORIZONTAL
  ScreenStack = []

  attr_reader :cwin, :rows, :cols, :width, :height, :scrolling
  attr_reader :r0, :c0
  attr_accessor :fg, :bg

  # Better to use Window.window IRL 

  def initialize(high=nil, wide=nil, r0=0, c0=0, border=false, 
                 fg=White, bg=Blue, scroll=false)
    @wide, @high, @r0, @c0 = wide, high, r0, c0
    @border, @fg, @bg      = border, fg, bg
    @cwin = Curses::Window.new(high, wide, r0, c0)
    colorize!(fg, bg)
    if @border
      @cwin.box(Vert, Horiz)
      @outer = @cwin
      @outer.refresh
      @cwin = Curses::Window.new(high-2, wide-2, r0+1, c0+1)
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
    main_win = Curses.init_screen
    Curses.start_color
    self.colorize!(main_win, fg, bg)
    rows, cols = main_win.maxy, main_win.maxx
    win = self.make(main_win, rows, cols, 0, 0, border: false,
              fg: fg, bg: bg, scroll: scroll)
    debug "...started #main"
    win
  rescue => err
    File.open("/tmp/main.out", "w") {|f| f.puts err.inspect; f.puts err.backtrace } 
  end

# FIXME try again to inline this

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

  def add_title(str, align = :center)
    raise "No border" unless @border
    len = str.length  # What if it's too long?
    start = case align
              when :left;   1
              when :center; (@outer.maxx - len)/2
              when :right;  @outer.maxx - len - 1
            end
    @outer.setpos 0, start
    @outer.addstr str
    @outer.refresh
  end

  # FIXME refactor bad code

  def scrolling(flag=true)
    @scrolling = flag
    @cwin.scrollok(flag)
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

  def screen_text(file = nil)   # rename?
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

  def background(high=STDSCR.rows, wide=STDSCR.cols, r=0, c=0)
    saveback(high, wide, r, c)
    yield
    restback(high, wide, r, c)
  end

  def saveback(high=STDSCR.rows, wide=STDSCR.cols, r=0, c=0)
    debug "saveback: #{[high, wide, r, c].inspect}"
    save = [self.rc]
    0.upto(high-1) do |h|
      0.upto(wide-1) do |w|
        row, col = h+r-1, w+c-1
        row += 1 if self == STDSCR   # wtf?
        col += 1 if self == STDSCR
        save << self[row, col]
      end
    end
    ScreenStack.push save
  end

  def restback(high=STDSCR.rows, wide=STDSCR.cols, r=0, c=0)
    save = ScreenStack.pop
    pos = save.shift
    0.upto(high-1) do |h|
      line = ""
      0.upto(wide-1) {|w| line << save.shift }
      row, col = h+r-1, c-1
      row += 1 if self == STDSCR   # wtf?
      col += 1 if self == STDSCR
      self.go row, col
      self.print line
    end
    self.go *pos
    @cwin.refresh
  rescue => err
    puts "Error!"
    puts err
    puts err.backtrace.join("\n")
    sleep 8
  end

  def fg=(sym)
    set_colors(fg, @bg)
  end

  def bg=(sym)
    set_colors(@fg, bg)
  end

  def beep
    Curses.beep
  end

  def flash
    Curses.flash
  end

end
