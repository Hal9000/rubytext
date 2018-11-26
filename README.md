# RubyText

RubyText is a curses wrapper that is in the early experimental
stages. The code has bugs. Running it may cause general bad luck
as well as demon infestation.

Install the `rubytext` gem and then run the demo or the slides
or both.

```
  $ gem install rubytext
  $ rubytext demo      # 2-minute demo
  $ rubytext slides    # longer "slideshow"
```

There is also `examples/ide.rb` ("world's simplest Ruby IDE").
It is _very_ dumb.  :)

### Getting started

Here's the obligatory hello-world program.

```ruby
require 'rubytext'

RubyText.start

puts "Hello, world!"

getch
```

You invoke `RubyText.start` to initialize the curses environment with default settings. If you
then use `puts`, it will write to the standard screen (called `STDSCR` in this library).

The `getch` (get character) simply waits for keyboard input before proceeding. Without it, the
program might terminate too fast for you to see anything.

## The "slideshow"

Here are some of the programs from the `rubytext slides` set of demos. See the `examples`
directory and the `showme.rb` script.

A simple window:
```ruby
require 'rubytext`
win = RubyText.window(6, 25, 2, 34, 
                      # 6 rows, 25 cols; upper left at 2,4
                      fg: Blue, bg: White) # foreground, background

win.puts "This is a window..."
```

How `output` works. This name may change.
```ruby
require 'rubytext`
win = RubyText.window(9, 36, 2, 6, fg: White, bg: Red) 

win.output do
  puts "Because this code uses #output,"
  puts "it doesn't have to specify the"
  puts "window as a receiver each time."
end
```

Windows are bordered by default.
```ruby
require 'rubytext`
win = RubyText.window(9, 35, 3, 7, border: false, fg: Black, bg: Green)

win.puts "A window doesn't have to"
win.puts "have a border."
```

Using `puts` will wrap around the window automagically.
```ruby
require 'rubytext`
win = RubyText.window(8, 39, 4, 9, fg: Black, bg: Blue)

win.puts "If your text is longer than " +
         "the width of the window, by default it will " +
         "wrap around."

win.puts "Scrolling is not yet supported."
```

Scrolling is not yet implemented.
```ruby
require 'rubytext`
win = RubyText.window(10, 70, 2, 14, fg: Yellow, bg: Black)

win.output do
  puts "Without scrolling, this is what happens when your window fills up..."
  puts "This behavior will probably change later."
  sleep 1
  puts "Let's print 10 more lines now:"
  sleep 1
  
  10.times {|i| puts "Printing line #{i}..."; sleep 0.2 }
end

```

You can use `print` and `p` as well as `puts`.
```ruby
require 'rubytext`
win = RubyText.window(10, 60, 2, 14, fg: Blue, bg: Black)

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

*More later...*

