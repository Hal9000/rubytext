win = RubyText.window(12, 60, 2, 5, true, fg: :yellow, bg: :blue)

win.puts "ABCDE    Method [] can retrieve characters "
win.puts "FGHIJ    from a window."
win.puts "KLMNO\nPQRST\nUVWZYZ"
win.puts

sleep 2
win.puts "(2,2) => '#{win[2,2]}'    (0,4)  => '#{win[0,4]}'"
win.puts "(6,7) => '#{win[6,7]}'    (0,15) => '#{win[0,15]}'"
