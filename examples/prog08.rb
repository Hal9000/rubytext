win = RubyText.window(12, 50, 0, 5, true, fg: :yellow, bg: :blue)

win.puts "We can use the []= method (0-based)"
win.puts "to address individual window locations"
win.puts "and place characters there.\n "

sleep 2
win[4,22] = "X"

sleep 2
win[8,20] = "y"

sleep 2
win[6,38] = "Z"
