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


*More later...*

