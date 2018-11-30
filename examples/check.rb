require 'rubytext'

RubyText.start(:raw, log: "foo", fg: :white, bg: :black)

cmax = STDSCR.cols
rmax = STDSCR.rows

rbest, cbest = 32, 80

RubyText.hide_cursor

if rmax < rbest || cmax < rbest
  puts "\n  Your window should be #{rbest}x#{cbest} or larger,"
  puts   "  but this one is only  #{rmax}x#{cmax}."
  puts "  Please resize and run again!"
  getch
  exit 1
end
