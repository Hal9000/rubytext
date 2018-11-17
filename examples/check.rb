require 'rubytext'

RubyText.start(:raw, fg: :white, bg: :black)

cmax = STDSCR.cols
rmax = STDSCR.rows

RubyText.hide_cursor

if rmax < 25 || cmax < 80
  puts "\n  Your window should be 25x80 or larger,"
  puts   "  but this one is only  #{rmax}x#{cmax}."
  puts "  Please resize and run again!"
  getch
  exit 1
end
