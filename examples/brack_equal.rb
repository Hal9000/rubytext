win = RubyText.window(11, 50, r: 2, c: 15, fg: Yellow, bg: Blue)

win.puts "We can use the []= method (0-based)"
win.puts "to address individual window locations"
win.puts "and place characters there.\n "

sleep 1; win[4,22] = "X"; win.refresh
sleep 1; win[8,20] = "y"; win.refresh
sleep 1; win[6,38] = "Z"; win.refresh
