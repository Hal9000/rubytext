def effect(*args) # find better way
  RubyText::Effects.new(*args)
end

fg, bg = White, Blue
win = RubyText.window(9, 65, 2, 26, fg: fg, bg: bg)

win.puts "This is EXPERIMENTAL (and BUGGY)."
win.puts "Use an \"effect\" to change the text color or \"look\":"

win.puts "This is", effect(win, Yellow), " another color ", 
          effect(win, White), "and yet another."
win.puts "We can ", effect(win, :bold), "boldface ",
         "and ", effect(win, :reverse), "reverse ",
         "and ", effect(win, :under), "underline ",
         effect(win, :normal), "text at will.\n "
win.puts "This is ", effect(win, :bold, Red), "bold red ", 
         effect(win, :normal, fg), "and this is normal again.\n "
