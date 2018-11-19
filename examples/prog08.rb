win = RubyText.window(10, 50, 0, 5, true, fg: :yellow, bg: :blue)

win.puts "We can use the []= method (0-based)"
win.puts "to address individual window locations"
win.puts "and place characters there.     [BUG!]\n "

sleep 2
win[4,2] = "X"

sleep 2
win[8,10] = "y"

sleep 2
win[6,18] = "Z"
