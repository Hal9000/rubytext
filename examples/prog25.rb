puts "If row (or column) is omitted for window placement,"
puts "the window will be screen-centered on one axis or both."

w1 = RubyText.window(3, 21, r: 6, c: 9); w1.puts "Both row and column"
w2 = RubyText.window(3, 21, r: 4);       w2.puts "Row, no column"
w3 = RubyText.window(3, 21, c: 4);       w3.puts "Column, no row"
w4 = RubyText.window(3, 21);             w4.puts "No row, no column"
