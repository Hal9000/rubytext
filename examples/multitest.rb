require 'rubytext'

RubyText.start(fg: White, bg: Black)

def any_key
  STDSCR.bottom
  print " "*30 + "Press any key..."
  getch
end

puts "Colors...\n "  # window must be >= 96 cols?

r0 = 3
Colors.each do |fg|
  c0 = 0
  Colors.each do |bg|
    win = RubyText.window(2, 12, r0, c0, border: false, fg: fg, bg: bg)
    win.puts " #{fg} on\n #{bg}"
    c0 += 14
  end
  r0 += 3
end

any_key

STDSCR.clear

15.times { puts }

puts "Here is some"
puts "  random text...\n "
sleep 2.5

STDSCR.scrolling(true)

puts "Scroll up 3..."
3.times { STDSCR.scroll; sleep 0.9 }

sleep 0.9

puts "... now scroll down 5."
5.times { STDSCR.scroll(-1); sleep 0.9 }

sleep 0.9
any_key
