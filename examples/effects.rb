def effect(*args) # find better way
  RubyText::Effects.new(*args)
end

fg, bg = White, Blue
win = RubyText.window(10, 65, r: 2, c: 26, fg: fg, bg: bg)

win.puts "This is EXPERIMENTAL (and BUGGY).\n"
win.puts "Use an \"effect\" to change the text color or \"look\":"

win.puts "This is", fx(" another color ", Yellow),
         fx("and yet another.", White)
win.puts "We can ", fx("boldface ",:bold), "and ", fx("underline ",:under),
         "and ", fx("reverse ",:reverse), fx("text at will.",:normal) 
win.puts
win.puts "This is ", effect(:bold, Red), "bold red ", 
         effect(:normal, fg), "and this is normal again.\n "
