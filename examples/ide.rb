$LOAD_PATH << "lib"

if ARGV.size != 2
  STDERR.puts "Usage: ruby ide.rb libname.rb progname.rb"
  exit
end

require 'rubytext'

RubyText.start

# print " "  # FIXME - bug requires this?

@lib, @code = ARGV

def menu
$debug.puts "Entering menu"
  @mywin.output do
#   boxme   # FIXME - dumb hack
    @mywin.clear
    puts
    puts " World's Simplest Ruby IDE\n "
    puts " Lib  = #{@lib}"
    puts " Code = #{@code}"
    puts 
    puts " 1  Edit lib"
    puts " 2  Edit code"
    puts " 3  Run code"
    puts " 4  pry"
    puts " 5  Shell"
    puts " 6  irb"
    puts " 7  RubyDocs"
    puts
    puts " 0  Quit"
    print "\n  Choice = "
    @mywin.refresh   # FIXME - dumb hack
  end
$debug.puts "Exiting menu"
end

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

@mywin = RubyText.window(19, 30, 1, 2, true)

loop do 
  menu
  cmd = getch.chr
  case cmd
    when "1"; system("vi #{@lib}")
    when "2"; system("vi #{@code}") 
    when "3"; system("tput clear; ruby #{@code}; sleep 5")
    when "4"; shell("pry")
    when "5"; shell("bash")
    when "6"; shell("irb")
    when "7"; system("open -a Safari http://ruby-doc.org")
    when "0"; exit
    else 
      @mywin.rcprint 12, 4, "\n\n  No such command '#{cmd}'"
      sleep 2
      next
  end
end

