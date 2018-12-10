def effect(*args) # find better way
  RubyText::Effects.new(*args)
end

fg, bg = White, Blue
win = RubyText.window(9, 65, 2, 26, fg: fg, bg: bg)

win.puts "This is EXPERIMENTAL (and BUGGY)."
win.puts "Use an \"effect\" to change the text color or \"look\":"

win.puts "This is", fx(" another color ", Yellow),
          effect(White), "and yet another."
win.puts "We can ", effect(:bold), "boldface ",
         "and ", effect(:reverse), "reverse ",
         "and ", effect(:under), "underline ",
         effect(:normal), "text at will.\n "
win.puts "This is ", effect(:bold, Red), "bold red ", 
         effect(:normal, fg), "and this is normal again.\n "
