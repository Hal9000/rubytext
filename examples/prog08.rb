win = RubyText.window(11, 50, 0, 5, fg: Yellow, bg: Blue)

win.puts "We can use the []= method (0-based)"
win.puts "to address individual window locations"
win.puts "and place characters there.\n "

sleep 2
win[4,22] = "X"; win.refresh

sleep 2
win[8,20] = "y"; win.refresh

sleep 2
win[6,38] = "Z"; win.refresh
