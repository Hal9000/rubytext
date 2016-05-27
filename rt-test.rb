require_relative './rubytext'

print "Here goes... "

ymax, xmax = STDSCR.rows, STDSCR.cols

puts "STDSCR is #{ymax.inspect} by #{xmax.inspect}"

print "\nI can write here "
sleep 1
puts "and then continue."

sleep 1
print "I can jump away "

sleep 1
STDSCR.go(20, 15) { puts "and print somewhere else" }
# ^ Same as: rcprint(20, 15, "and print somewhere else" }

sleep 1
puts "and then return."

sleep 2
print "I can hide the cursor --> "
sleep 1
RubyText.hide_cursor
puts  # Bug: This is needed. Cursor doesn't disappear immediately.


sleep 1
puts "\nNow watch as I create a window:"

mywin = RubyText.window(16, 40, 8, 4, true)

sleep 1
mywin.puts "\nNow I'm writing in a window."
mywin.puts "\nIts size is  #{mywin.rows} rows by #{mywin.cols} cols"
mywin.puts "(or #{mywin.height}x#{mywin.width} with the frame).\n "

sleep 1
mywin.puts "I always try to honor the borders of my window."

sleep 1
mywin.puts "\nWatch as I place 50 random stars here..."

sleep 2

50.times do
  r = rand(mywin.rows)
  c = rand(mywin.cols)
  sleep 0.05
  mywin.rcprint(r, c, "*")
end

sleep 2
mywin.output do
  mywin.clear
  puts "The window method called 'output'"
  puts "will temporarily override STDSCR so that (in the code)"
  puts "we don't have to use the window name over and over for stream I/O."
  sleep 2
  STDSCR.rcprint 25, 3, "Of course I can still print here if I want."
  sleep 2
  puts "\nOne moment..."
  sleep 5
end

mywin.output do
  mywin.clear
  puts "The []= method allows us to place characters in"
  puts "the window (without auto-refresh)."
  puts "\nLet's see the '50 stars' trick again:"
  sleep 2
  50.times do
    r = rand(mywin.rows)
    c = rand(mywin.cols)
    mywin[r, c] =  "*"
  end
  mywin.win.refresh 
end

sleep 3
mywin.output do
  mywin.clear
  mywin.puts "The [] method is still buggy, but let's try it."
  mywin.puts "XYZ"
  ch = mywin[2,2]
  mywin.puts "The char at [2,2] is: #{ch.chr.inspect}"
end

sleep 4
mywin.puts "\nThat's all for now."
mywin.puts "\nPress any key to exit."

getch
