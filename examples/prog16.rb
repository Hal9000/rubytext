win = RubyText.window(11, 65, 1, 6, fg: Blue, bg: White)

win.puts "Methods up/down/left/right can also take an integer..."

win.go 4, 29;               win.putch("+"); sleep 1
win.go 4, 29; win.up(2);    win.putch("2"); sleep 1
win.go 4, 29; win.down(3);  win.putch("3"); sleep 1
win.go 4, 29; win.left(4);  win.putch("4"); sleep 1
win.go 4, 29; win.right(5); win.putch("5"); sleep 1
