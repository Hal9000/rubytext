win = RubyText.window(11, 65, 0, 6, true, fg: Blue, bg: White)

win.go 2,0
win.puts "   Method #home will home the cursor..."
win.puts "   and #putch will put a character at the current location."
sleep 2
win.home; win.putch "H"; sleep 2
win.rcprint 4,3, "We can also move up/down/left/right..."; sleep 2

win.go 7, 29;            win.putch("+"); sleep 1
win.go 7, 29; win.up;    win.putch("U"); sleep 1
win.go 7, 29; win.down;  win.putch("D"); sleep 1
win.go 7, 29; win.left;  win.putch("L"); sleep 1
win.go 7, 29; win.right; win.putch("R"); sleep 1
