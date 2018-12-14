win = RubyText.window(11, 65, r: 4, c: 14, fg: Blue, bg: White)

win.go 2,0
win.puts "#top and #bottom are the same as #up! and #down!"

win.go 5, 21;             win.putch("+"); sleep 1
win.go 5, 21; win.top;    win.putch("T"); sleep 1
win.go 5, 21; win.bottom; win.putch("B"); sleep 1
