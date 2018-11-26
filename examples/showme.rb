require 'rubytext'
require 'timeout'

def next_slide
  RubyText.hide_cursor
  sleep 2
  Timeout.timeout(999) do
    STDSCR.go @rmax-1-@upward, 0
    STDSCR.center "Press any key..."
    getch
  end
rescue Timeout::Error
end

def show_code(prog, upward=0)
  text = File.read(prog)
  nlines = text.split("\n").size

  prog_top = @rmax-nlines-3 - upward.to_i
  code = RubyText.window(nlines+2, @cmax-2, prog_top, 1, 
                         fg: Green, bg: Black)
  code.puts text

  right = STDSCR.cols - prog.length - 8
  STDSCR.go prog_top, right 
  STDSCR.print "[ #{prog} ]"
  STDSCR.go 0,0
end

def check_window
  if @rmax < 25 || @cmax < 80
    puts "\n  Your window should be 25x80 or larger,"
    puts   "  but this one is only  #{@rmax}x#{@cmax}."
    puts "  Please resize and run again!"
    getch
    exit 1
  end
end

#### Main

RubyText.start(:cbreak, log: "/tmp/showme.log", fg: White, bg: Black)

@cmax = STDSCR.cols
@rmax = STDSCR.rows

RubyText.hide_cursor

check_window

prog, @upward = ARGV
@upward ||= 0

show_code(prog, @upward)

require_relative prog

next_slide # if @upward == 0
