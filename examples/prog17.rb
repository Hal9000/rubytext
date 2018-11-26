win = RubyText.window(11, 65, 1, 6, true, fg: Blue, bg: White)

win.go 2,0
win.puts "We also have: up!, down!, left!, and right! which can" 
win.puts "Take us to the edges of the window."

win.go 5, 21;             win.putch("+"); sleep 1
win.go 5, 21; win.up!;    win.putch("U"); sleep 1
win.go 5, 21; win.down!;  win.putch("D"); sleep 1
win.go 5, 21; win.left!;  win.putch("L"); sleep 1
win.go 5, 21; win.right!; win.putch("R"); sleep 1
