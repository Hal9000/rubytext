$LOAD_PATH.unshift "lib"

require 'rubytext'

def delay(sec)
  sleep sec/2.0
end

RubyText.start(:color, log: "mylog.txt", fg: :green, bg: :black)

print "Here goes... "
delay 2

ymax, xmax = STDSCR.rows, STDSCR.cols

puts "STDSCR is #{ymax.inspect} by #{xmax.inspect}"
delay 2

print "\nI can write here "
delay 2
puts "and then continue."

delay 2
print "I can jump away "

delay 2
STDSCR.go(20, 15) { puts "and print somewhere else" }
# ^ Same as: rcprint(20, 15, "and print somewhere else" }

delay 2
puts "and then return."

delay 3
print "I can hide the cursor... "
delay 1
RubyText.hide_cursor
delay 1
print "then show it again... "
delay 1
RubyText.show_cursor
delay 1
print "and hide it again. "
RubyText.hide_cursor
delay 3

puts "\n\nNow watch as I create a window:"

mywin = RubyText.window(16, 40, 8, 14, true, fg: :blue, bg: :yellow)

delay 3
mywin.puts "\nNow I'm writing in a window."
mywin.puts "\nIts size is  #{mywin.rows} rows by #{mywin.cols} cols"
mywin.puts "(or #{mywin.height}x#{mywin.width} with the frame).\n "

delay 4
mywin.puts "I always try to honor the borders of my window."

delay 2
mywin.puts "\nWatch as I place 50 random stars here..."

delay 2

50.times do
  r = rand(mywin.rows)
  c = rand(mywin.cols)
  delay 0.1
  mywin.rcprint(r, c, "*")
end

delay 4
mywin.output do
  mywin.clear
  puts "The window method called 'output'"
  puts "will temporarily override STDSCR so that (in the code)"
  puts "we don't have to use the window name over and over for stream I/O."
  delay 4
  STDSCR.rcprint 25, 3, "Of course I can still print here if I want."
  delay 3
  puts "\nOne moment..."
  delay 4
end

mywin.output do
  mywin.clear
  puts "The []= method allows us to place characters in"
  puts "the window (without auto-refresh)."
  puts "\nLet's see the '50 stars' trick again:"
  delay 5
  50.times do
    r = rand(mywin.rows)
    c = rand(mywin.cols)
    mywin[r, c] =  "*"
  end
  mywin.win.refresh 
end

delay 5
mywin.output do
  mywin.clear
  mywin.puts "The [] method (zero-based) is still buggy, but let's try it."
  mywin.puts "XYZ"
  ch = mywin[2,2]
  mywin.puts "The char at [2,2] is: #{ch.chr.inspect}"
end

delay 4
mywin.puts "\nThat's all for now."
delay 1
mywin.puts "\nPress any key to exit."

getch
