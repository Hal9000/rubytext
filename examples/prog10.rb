win = RubyText.window(6, 30, 2, 5, fg: Yellow, bg: Blue)

win.puts "You can write to a window..."

sleep 2
9.times { STDSCR.puts }
STDSCR.puts "...or you can write to STDSCR (standard screen)"

sleep 1
puts "STDSCR is the default receiver."

sleep 2
STDSCR.go 5, 0
puts "Nothing stops you from overwriting a window."

