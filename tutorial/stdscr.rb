require 'rubytext'

RubyText.start(fg: Yellow, bg: Blue)

puts "This writes by default to STDSCR"
STDSCR.puts "and this does the same thing.\n "

print "Only one line "
print "of output "
print "printed "
puts  "here."

puts

array = [1, 2, 3, 4, 5]

puts "p also works:"
p array

puts

getch
