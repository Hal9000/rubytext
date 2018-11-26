win = RubyText.window(6, 25, 2, 34, 
                      # 6 rows, 25 cols; upper left at 2,4
                      true, # has a border
                      fg: Blue, bg: White) # foreground, background

win.puts "This is a window..."
