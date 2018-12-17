require 'rubytext'

RubyText.start

win = RubyText.window(16, 60, r: 3, c: 10, fg: Yellow, bg: Blue)

win.puts "ABCDE    Method [] can retrieve characters "
win.puts "FGHIJ    from a window."
win.puts "KLMNO\nPQRST\nUVWZYZ\n "

sleep 1
win.puts "(3,2) => '#{win[3,2]}'    (0,4)  => '#{win[0,4]}'"
win.puts "(7,7) => '#{win[7,7]}'    (0,15) => '#{win[0,15]}'"

sleep 1
win.puts "\nAnd []= can place characters at screen locations."

sleep 1
win[12, 15] = "a"; win.refresh; sleep 0.4
win[11, 25] = "b"; win.refresh; sleep 0.4
win[10, 35] = "c"
getch
