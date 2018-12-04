if ARGV.size != 2
  STDERR.puts "Usage: ruby ide.rb libname.rb progname.rb"
  exit
end

require 'rubytext'

RubyText.start

@lib, @code = ARGV

def shell(str)
  STDSCR.clear
  RubyText.show_cursor
  system("stty sane")   # FIXME - dumb hack
  STDSCR.puts "\n\n  When you exit, you will\n  return to the IDE.\n "
  system(str)
  X.noecho   # FIXME Shouldn't have to do this stuff
  X.stdscr.keypad(true)
  X.cbreak   # by default
end

items = ["Edit lib",   # 0
         "Edit code",  # 1
         "Run code",   # 2
         "pry",        # 3
         "Shell",      # 4
         "irb",        # 5
         "RubyDocs",   # 6
         "Quit"]       # 7

def show
  STDSCR.clear
  puts
  puts " World's Simplest Ruby IDE\n "
  puts " Lib  = #{@lib}"
  puts " Code = #{@code}"
  puts 
end

loop do
  show
  n, str = RubyText.menu(r: 10, c: 5, items: items)
puts n.inspect
  case n
    when 0; system("vi #{@lib}")
    when 1; system("vi #{@code}") 
    when 2; system("tput clear; ruby #{@code}; sleep 5")
    when 3; shell("pry")
    when 4; shell("bash")
    when 5; shell("irb")
    when 6; system("open -a Safari http://ruby-doc.org")
    when 7; exit
  end
end

