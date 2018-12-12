win = RubyText.window(10, 45, 1, 20, fg: Black, bg: Red)
win.puts "This very crude menu is also EXPERIMENTAL."
win.puts "It knows up, down, Enter, and Escape.\n "
win.puts "Press any key to display the menu..."
win.puts

getch

days = %w[Monday Tuesday Wednesday Thursday Friday]
num, day = RubyText.menu(win: win, r: 1, c: 5, items: days)

puts
if day.nil?
  win.puts "You picked nothing!"
else
  win.puts "You picked item #{num} which is #{day.inspect}"
end
