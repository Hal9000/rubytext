puts "This very crude menu is also EXPERIMENTAL."
puts "At the moment, it only works inside STDSCR!\n"
puts "It knows up, down, Enter, and Escape.\n "
puts "Press any key to display the menu..."
getch

days = %w[Monday Tuesday Wednesday Thursday Friday]
picked = RubyText.menu(c: 30, items: days)

puts
if picked.nil?
  puts "You picked nothing!"
else
  puts "You picked item #{picked} which is #{days[picked].inspect}"
end
