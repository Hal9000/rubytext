win = RubyText.window(6, 25, 2, 4, 
                      # 6 rows, 25 cols; upper left at 2,4
                      true, # has a border
                      fg: :blue, bg: :white) # foreground, background

win.puts "This is a window..."
