win = RubyText.window(10, 50, 2, 5, true, fg: :yellow, bg: :blue)

win.puts "We can use the []= method (0-based)"
win.puts "to address individual window locations"
win.puts "and place characters there.\n "

sleep 2
win[4,2] = "X"

sleep 2
win[6,20] = "y"

sleep 2
win[8,8] = "Z"
