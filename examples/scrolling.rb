STDSCR.scrolling(true)

puts "We use #scrolling to turn the scrolling feature on or off"
puts "for any window (including STDSCR). It's off by default."

win2 = RubyText.window(6, 50, r: 6, c: 29, fg: Blue, bg: Black)
win2.puts "\nThis is\njust some more\nrandom text..."
win2.scrolling(true)

puts "\nNote that we can scroll up or down... but there is no \"buffer\" for text."
sleep 3
3.times { win2.scroll(1); sleep 0.2 };  sleep 1
3.times { win2.scroll(-1); sleep 0.2 }; sleep 4

puts "\nNOTE: If you scroll STDSCR, other windows will disappear! This may be fixed later."
sleep 3
3.times { STDSCR.scroll(-1); sleep 0.2 }
