win = RubyText.window(8, 39, 4, 9, fg: Black, bg: Blue)

win.puts "If your text is longer than " +
         "the width of the window, by default it will " +
         "wrap around."

win.puts "Scrolling is not yet supported."
