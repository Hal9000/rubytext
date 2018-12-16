win = RubyText.window(8, 39, r: 7, c: 14, fg: Black, bg: Blue)

win.puts "If your text is longer than " +
         "the width of the window, by default it will " +
         "wrap around."

win.puts "Scrolling is OFF by default."
