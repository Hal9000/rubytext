def fx(*args) # find better way
  RubyText::Effects.new(*args)
end

fg, bg = White, Blue
win = RubyText.window(9, 65, 2, 26, fg: fg, bg: bg)

win.puts "This is EXPERIMENTAL (and BUGGY)."
win.puts "Use an \"effect\" to change the text color or \"look\":"

win.puts "This is", fx(win, Yellow), " another color ", 
          fx(win, White), "and yet another."
win.puts "We can ", fx(win, :bold), "boldface ",
         "and ", fx(win, :reverse), "reverse ",
         "and ", fx(win, :under), "underline ",
         fx(win, :normal), "text at will.\n "
win.puts "This is ", fx(win, :bold, Red), "bold red ", 
         fx(win, :normal, fg), "and this is normal again.\n "
