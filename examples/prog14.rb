win = RubyText.window(13, 65, r: 2, c: 14, fg: Blue, bg: White)

win.puts "The #rcprint method will print at the specified"
win.puts "row/column, like go(r,c) followed by a print,"
win.puts "except that it does NOT move the cursor."

win.rcprint 4,8,  "Simplify,"
win.rcprint 6,12, "simplify,"
win.rcprint 8,16, "simplify!"

win.rcprint 10,0, "Later there will be other ways to do this kind of thing."
