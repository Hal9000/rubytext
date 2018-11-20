win = RubyText.window(12, 65, 0, 6, true, fg: :green, bg: :blue)

win.puts "This is EXPERIMENTAL."
win.puts "Use a color symbol to change text color temporarily:\n "

win.puts "This is", :yellow, " another color", :white, " and yet another."
win.puts "And this is normal again.\n "

win.puts "This does mean that you can't print a symbol that is"
win.puts "also a color name... you'd need a workaround.\n "

sym = :red
win.puts "The symbol is ", sym.inspect, " which works", sym, " just fine."
