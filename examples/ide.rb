$LOAD_PATH << "lib"

if ARGV.size != 2
  STDERR.puts "Usage: ruby ide.rb libname.rb progname.rb"
  exit
end

require 'rubytext'

print " "  # FIXME - bug requires this?

@lib, @code = ARGV

def menu
$debug.puts "Entering menu"
  m = @mywin
  m.boxme   # FIXME - dumb hack
  m.clear
  m.puts
  m.puts " World's Simplest Ruby IDE\n "
  m.puts " Lib  = #{@lib}"
  m.puts " Code = #{@code}"
  m.puts 
  m.puts " 1  Edit lib"
  m.puts " 2  Edit code"
  m.puts " 3  Run code"
  m.puts " 4  pry"
  m.puts " 5  Shell"
  m.puts " 6  irb"
  m.puts " 7  RubyDocs"
  m.puts
  m.puts " 0  Quit"
  m.print "\n  Choice = "
  m.refresh   # FIXME - dumb hack
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
  # $debug.puts "about to call getch"
  cmd = getch.chr
  # $debug.puts "called getch - '#{cmd}'"
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

