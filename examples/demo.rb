$LOAD_PATH << "lib"

require 'rubytext'

RubyText.start(:color, log: "mylog.txt", fg: :green)

print "Here goes... "
sleep 2

ymax, xmax = STDSCR.rows, STDSCR.cols

puts "STDSCR is #{ymax.inspect} by #{xmax.inspect}"
sleep 2

print "\nI can write here "
sleep 2
puts "and then continue."

sleep 2
print "I can jump away "

sleep 2
STDSCR.go(20, 15) { puts "and print somewhere else" }
# ^ Same as: rcprint(20, 15, "and print somewhere else" }

sleep 2
puts "and then return."

sleep 3
print "I can hide the cursor --> "
sleep 2
RubyText.hide_cursor
puts  # Bug: This is needed. Cursor doesn't disappear immediately.

sleep 2
puts "\nNow watch as I create a window:"

mywin = RubyText.window(16, 40, 8, 4, true)

sleep 3
mywin.puts "\nNow I'm writing in a window."
mywin.puts "\nIts size is  #{mywin.rows} rows by #{mywin.cols} cols"
mywin.puts "(or #{mywin.height}x#{mywin.width} with the frame).\n "

sleep 4
mywin.puts "I always try to honor the borders of my window."

sleep 2
mywin.puts "\nWatch as I place 50 random stars here..."

sleep 2

50.times do
  r = rand(mywin.rows)
  c = rand(mywin.cols)
  sleep 0.1
  mywin.rcprint(r, c, "*")
end

sleep 4
mywin.output do
  mywin.clear
  puts "The window method called 'output'"
  puts "will temporarily override STDSCR so that (in the code)"
  puts "we don't have to use the window name over and over for stream I/O."
  sleep 4
  STDSCR.rcprint 25, 3, "Of course I can still print here if I want."
  sleep 3
  puts "\nOne moment..."
  sleep 4
end

mywin.output do
  mywin.clear
  puts "The []= method allows us to place characters in"
  puts "the window (without auto-refresh)."
  puts "\nLet's see the '50 stars' trick again:"
  sleep 5
  50.times do
    r = rand(mywin.rows)
    c = rand(mywin.cols)
    mywin[r, c] =  "*"
  end
  mywin.win.refresh 
end

sleep 5
mywin.output do
  mywin.clear
  mywin.puts "The [] method (zero-based) is still buggy, but let's try it."
  mywin.puts "XYZ"
  ch = mywin[2,2]
  mywin.puts "The char at [2,2] is: #{ch.chr.inspect}"
end

sleep 4
mywin.puts "\nThat's all for now."
sleep 1
mywin.puts "\nPress any key to exit."

getch
