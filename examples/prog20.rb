def fx(*args) # find better way
  RubyText::Effects.new(*args)
end

win = RubyText.window(9, 65, 2, 26, fg: Green, bg: Blue)
fg, bg = Green, Blue

win.puts "This is EXPERIMENTAL."
win.puts "Use an \"effect\" to change the color or \"look\""
win.puts "of the text (temporarily):\n "

win.puts "This is", fx(win, Yellow), " another color ", 
          fx(win, White), "and yet another."
win.puts "This is ", fx(win, :bold, Red), "bold red ", 
         fx(win, :normal, fg), "and this is normal again.\n "
