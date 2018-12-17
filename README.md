# RubyText

RubyText is a curses wrapper that is in the early experimental
stages. Unlike some similar projects, it is a "thick" wrapper;
I am adding functionality that does not always correspond directly
to the curses world. 

Install the `rubytext` gem and then run the demo or the slides
or both.

```
  $ gem install rubytext
  $ rubytext demo      # 2-minute demo
  $ rubytext slides    # Longer "slideshow"
  $ rubytext tutorial  # (On OS/X) opens tutorial.html
```

### Getting started

Here's the obligatory hello-world program.

```ruby
require 'rubytext'

RubyText.start

puts "Hello, world!"

getch
```

<img src=readme-images/hw.png>

You invoke `RubyText.start` to initialize the curses environment with default settings. If you
then use `puts`, it will write to the standard screen (called `STDSCR` in this library).

The `getch` (get character) simply waits for keyboard input before proceeding. Without it, the
program might terminate too fast for you to see anything.

## The "slideshow"

Here are some of the programs from the `rubytext slides` set of demos. See the `examples`
directory and the `showme.rb` script.

A simple window:
```ruby
require 'rubytext'
win = RubyText.window(6, 25, r: 2, c: 34, 
                      # 6 rows, 25 cols; upper left at 2,4
                      fg: Blue, bg: White) # foreground, background

win.puts "This is a window..."
```

<img src=readme-images/prog01.png>


How `output` works. This name may change.
```ruby
require 'rubytext'
win = RubyText.window(9, 36, r: 2, c: 6, fg: White, bg: Red) 

win.output do
  puts "Because this code uses #output,"
  puts "it doesn't have to specify the"
  puts "window as a receiver each time."
end
```

Windows are bordered by default.
```ruby
require 'rubytext'
win = RubyText.window(9, 35, r: 3, c: 7, border: false, fg: Black, bg: Green)

win.puts "A window doesn't have to"
win.puts "have a border."
```

Using `puts` will wrap around the window automagically.
```ruby
require 'rubytext'
win = RubyText.window(8, 39, r: 4, c: 9, fg: Black, bg: Blue)

win.puts "If your text is longer than " +
         "the width of the window, by default it will " +
         "wrap around."
```

<img src=readme-images/noscroll.png>

Scrolling is not enabled by default for a window (except STDSCR).

```ruby
require 'rubytext'
win = RubyText.window(10, 70, r: 2, c: 14, fg: Yellow, bg: Black)

win.output do
  puts "Without scrolling, this is what happens when your window fills up..."
  puts "This behavior will probably change later."
  sleep 1
  puts "Let's print 10 more lines now:"
  sleep 1
  
  10.times {|i| puts "Printing line #{i}..."; sleep 0.2 }
end
```

<img src=readme-images/window_full.png>

You can use `print` and `p` as well as `puts`.

```ruby
require 'rubytext'
win = RubyText.window(10, 60, r: 2, c: 14, fg: Blue, bg: Black)

win.output do
  puts "The #print and #p methods also act as you expect."

  print "This will all "
  print "go on a single "
  puts "line."

  puts
  array = [1, 2, 3]
  p array
end
```

You can still use `puts` (etc.) with files, but watch for `STDOUT` and `STDERR`.

```ruby
require 'rubytext'
win = RubyText.window(10, 50, r: 0, c: 5, fg: Yellow, bg: Blue)

win.output do
  puts "Of course, #puts and #print are unaffected \nfor other receivers."

  out = File.new("/tmp/junk", "w")
  out.puts "Nothing to see here."
  sleep 2

  print "\nHowever, if you print to STDOUT or STDERR \nwithout redirection, "
  STDOUT.print "you will have some "
  STDERR.print "unexpected/undefined results "
  puts " in more ways than one."
end

```

Use `[]=` to stuff single characters into a window (like an array).
```ruby
require 'rubytext'
win = RubyText.window(11, 50, r: 0, c: 5, fg: Yellow, bg: Blue)

win.puts "We can use the []= method (0-based)"
win.puts "to address individual window locations"
win.puts "and place characters there.\n "

sleep 2
win[4,22] = "X"; win.refresh

sleep 2
win[8,20] = "y"; win.refresh

sleep 2
win[6,38] = "Z"; win.refresh
```

Likewise use `[]` to retrieve characters from a window.
```ruby
require 'rubytext'
win = RubyText.window(12, 60, r: 2, c: 5, fg: Yellow, bg: Blue)

win.puts "ABCDE    Method [] can retrieve characters "
win.puts "FGHIJ    from a window."
win.puts "KLMNO\nPQRST\nUVWZYZ"
win.puts

sleep 2
win.puts "(2,2) => '#{win[2,2]}'    (0,4)  => '#{win[0,4]}'"
win.puts "(6,7) => '#{win[6,7]}'    (0,15) => '#{win[0,15]}'"
```

You can write to `STDSCR` or to a subwindow.
```ruby
require 'rubytext'
win = RubyText.window(6, 30, r: 2, c: 5, fg: Yellow, bg: Blue)

win.puts "You can write to a window..."

sleep 2
9.times { STDSCR.puts }
STDSCR.puts "...or you can write to STDSCR (standard screen)"

sleep 1
puts "STDSCR is the default receiver."

sleep 2
STDSCR.go 5, 0
puts "Nothing stops you from overwriting a window."

```

You can retrieve cursor position and window size.
```ruby
require 'rubytext'
win = RubyText.window(12, 65, r: 1, c: 5, fg: Yellow, bg: Blue)

win.output do
  puts "You can detect the size and cursor position of any window."
  puts "\nSTDSCR is #{STDSCR.rows} rows by #{STDSCR.cols} columns"
  puts "win is     #{win.rows} rows by #{win.cols} columns"
  puts "\nSlightly Heisenbergian report of cursor position:"
  puts "  STDSCR.rc = #{STDSCR.rc.inspect}\n  win.rc    = #{win.rc.inspect}"
  puts "\nFor fun, I'll print \"ABC\" to STDSCR..."
  sleep 2
  STDSCR.print "ABC"
end
```

Move the cursor with `go` (and use a block to jump/return).
```ruby
require 'rubytext'
win = RubyText.window(11, 65, r: 0, c: 15, fg: Blue, bg: Black)

win.puts "The #go method will move the cursor to a specific location."
win.go 2, 5
win.puts "x  <-- The x is at 2,5"

win.puts "\nWith a block, it will execute the block and then"
win.puts "return to its previous location."

win.print "\n   ABC..."
sleep 2
win.go(8, 20) { win.print "XYZ" }
sleep 2
win.print "DEF"
```

Use `rcprint` to print at specific coordinates.
```ruby
require 'rubytext'
win = RubyText.window(13, 65, r: 0, c: 6, fg: Blue, bg: White)

win.puts "The #rcprint method will print at the specified"
win.puts "row/column, like go(r,c) followed by a print,"
win.puts "except that it does NOT move the cursor."

win.rcprint 4,8,  "Simplify,"
win.rcprint 6,12, "simplify,"
win.rcprint 8,16, "simplify!"

win.rcprint 10,0, "Later there will be other ways to do this kind of thing."
```

Window navigation: `home`, `up`, `down`, `left`, `right`
```ruby
require 'rubytext'
win = RubyText.window(11, 65, r: 0, c: 6, fg: Blue, bg: White)

win.go 2,0
win.puts "   Method #home will home the cursor..."
win.puts "   and #putch will put a character at the current location."
sleep 2
win.home; win.putch "H"; sleep 2
win.rcprint 4,3, "We can also move up/down/left/right..."; sleep 2

win.go 7, 29;            win.putch("+"); sleep 1
win.go 7, 29; win.up;    win.putch("U"); sleep 1
win.go 7, 29; win.down;  win.putch("D"); sleep 1
win.go 7, 29; win.left;  win.putch("L"); sleep 1
win.go 7, 29; win.right; win.putch("R"); sleep 1
```

More navigation: `up`, `down`, `left`, `right` with a parameter.
```ruby
require 'rubytext'
win = RubyText.window(11, 65, r: 1, c: 6, fg: Blue, bg: White)

win.puts "Methods up/down/left/right can also take an integer..."

win.go 4, 29;               win.putch("+"); sleep 1
win.go 4, 29; win.up(2);    win.putch("2"); sleep 1
win.go 4, 29; win.down(3);  win.putch("3"); sleep 1
win.go 4, 29; win.left(4);  win.putch("4"); sleep 1
win.go 4, 29; win.right(5); win.putch("5"); sleep 1
```

Still more navigation: `up!`, `down!`, `left!`, `right!`
```ruby
require 'rubytext'
win = RubyText.window(11, 65, r: 1, c: 6, fg: Blue, bg: White)

win.go 2,0
win.puts "We also have: up!, down!, left!, and right! which can" 
win.puts "Take us to the edges of the window."

win.go 5, 21;             win.putch("+"); sleep 1
win.go 5, 21; win.up!;    win.putch("U"); sleep 1
win.go 5, 21; win.down!;  win.putch("D"); sleep 1
win.go 5, 21; win.left!;  win.putch("L"); sleep 1
win.go 5, 21; win.right!; win.putch("R"); sleep 1
```

And finally, `top` and `bottom`.
```ruby
require 'rubytext'
win = RubyText.window(11, 65, r: 1, c: 6, fg: Blue, bg: White)

win.go 2,0
win.puts "#top and #bottom are the same as #up! and #down!"

win.go 5, 21;             win.putch("+"); sleep 1
win.go 5, 21; win.top;    win.putch("T"); sleep 1
win.go 5, 21; win.bottom; win.putch("B"); sleep 1
```

Somewhat useless, but there is a `center` method.
```ruby
require 'rubytext'
win = RubyText.window(15, 65, r: 1, c: 6, fg: Green, bg: Blue)

win.puts "#center will print text centered on the current row"
win.puts "and do an implicit CRLF at the end.\n "

stuff = ["I","can","never","imagine","good sets","of real words",
         "which can somehow", "produce tree shapes", "|", "|"]

stuff.each {|str| win.center(str) }

```

Changing colors during printing. This syntax will change.
```ruby
require 'rubytext'
win = RubyText.window(12, 65, r: 0, c: 6, fg: Green, bg: Blue)

win.puts "This is EXPERIMENTAL."
win.puts "Use a color symbol to change text color temporarily:\n "

win.puts "This is", :yellow, " another color", :white, " and yet another."
win.puts "And this is normal again.\n "

win.puts "This does mean that you can't print a symbol that is"
win.puts "also a color name... you'd need a workaround.\n "

sym = :red
win.puts "The symbol is ", sym.inspect, " which works", sym, " just fine."
```

A simple menu (incomplete, still experimental).
```ruby
require 'rubytext'
puts "This very crude menu is also EXPERIMENTAL."
puts "At the moment, it only works inside STDSCR!\n"
puts "It knows up, down, Enter, and Escape.\n "
puts "Press any key to display the menu..."
getch

days = %w[Monday Tuesday Wednesday Thursday Friday]
num, day = STDSCR.menu(c: 30, items: days)

puts
if day.nil?
  puts "You picked nothing!"
else
  puts "You picked item #{num} which is #{day.inspect}"
end
```

DESC
```ruby
require 'rubytext'
```

A marquee or ticker example. This uses threads and is kind of cool.
```ruby
require 'rubytext'
msg = <<~EOS
 A "ticker" example that actually uses threads. Maybe Curses is not as slow as 
 you thought? PRESS ANY KEY TO EXIT...
EOS

w, h = STDSCR.cols, STDSCR.rows - 1
threads = []

r = RubyText
t1 = -> { r.ticker(text: msg, row: h-8, col: 20, width: w-40, delay: 0.02, fg: Red, bg: Black) }
t2 = -> { r.ticker(text: msg, row: h-6, col: 15, width: w-30, delay: 0.04) }
t3 = -> { r.ticker(text: msg, row: h-4, col: 10, width: w-20, delay: 0.06, fg: Black, bg: Green) }
t4 = -> { r.ticker(text: msg, row: h-2, col:  5, width: w-10, delay: 0.08, bg: Black) }
t5 = -> { r.ticker(text: msg) }  # All defaults -- goes at bottom

threads << Thread.new { t1.call } << Thread.new { t2.call } << Thread.new { t3.call } << 
           Thread.new { t4.call } << Thread.new { t5.call }

threads << Thread.new { getch; exit }   # quitter thread...
threads.each {|t| t.join } 
```

<img src=readme-images/prog22.png>



*More later...*

