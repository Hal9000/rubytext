win = RubyText.window(8, 39, 4, 9, true, fg: :black, bg: :blue)

win.puts "If your text is longer than " +
         "the width of the window, by default it will " +
         "wrap around."

win.puts "Scrolling is not yet supported."
