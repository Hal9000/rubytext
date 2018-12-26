win = RubyText.window(13, 65, r: 2, c: 14, fg: Blue, bg: White)

win.puts "The #rcprint method will print at the specified"
win.puts "row/column, like go(r,c) followed by a print,"
win.puts "except that it does NOT move the cursor.\n "

win.rcprint 6,8,  "Simplify,"
win.rcprint 8,12, "simplify,"
win.rcprint 10,16, "simplify!"

win.puts "Later there will be other ways to do this kind of thing."
