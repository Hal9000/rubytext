puts "This very crude menu is also EXPERIMENTAL."
puts "At the moment, it only works inside STDSCR!\n"
puts "It knows up, down, Enter, and Escape.\n "
puts "Press any key to display the menu..."
getch

days = %w[Monday Tuesday Wednesday Thursday Friday]
num, day = RubyText.menu(c: 30, items: days)

puts
if day.nil?
  puts "You picked nothing!"
else
  puts "You picked item #{num} which is #{day.inspect}"
end
