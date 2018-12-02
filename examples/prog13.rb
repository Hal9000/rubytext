win = RubyText.window(11, 65, 2, 15, fg: Blue, bg: Black)

win.puts "The #go method will move the cursor to a specific location."
win.go 2, 5
win.puts "x  <-- The x is at 2,5"

win.puts "\nWith a block, it will execute the block and then"
win.puts "return to its previous location."

win.print "\n   ABC..."
sleep 2
win.go(8, 20) { win.print "XYZ" }
sleep 2
win.print "DEF"
