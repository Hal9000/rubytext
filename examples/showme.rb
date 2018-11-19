require 'rubytext'
require 'timeout'

def next_slide
  RubyText.hide_cursor
  sleep 2
  Timeout.timeout(999) do
    STDSCR.go @rmax-1, 0
    STDSCR.center "Press any key..."
    getch
  end
rescue Timeout::Error
end

def show_code(prog)
  text = File.read(prog)
  nlines = text.split("\n").size

  prog_top = @rmax-nlines-3
  code = RubyText.window(nlines+2, @cmax-2, prog_top, 1, 
                         true, fg: :green, bg: :black)
  code.puts text

  STDSCR.go prog_top, 61
  STDSCR.print "[ #{prog} ]"
  STDSCR.go 0,0
end

def check_window
  if @rmax < 25 || @cmax < 80
    puts "\n  Your window should be 25x80 or larger,"
    puts   "  but this one is only  #{rmax}x#{cmax}."
    puts "  Please resize and run again!"
    getch
    exit 1
  end
end

#### Main

RubyText.start(:cbreak, log: "showme.log", fg: :white, bg: :black)

@cmax = STDSCR.cols
@rmax = STDSCR.rows

RubyText.hide_cursor

check_window

prog = ARGV.first

show_code(prog)

require_relative prog

next_slide
