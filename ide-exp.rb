require_relative './rubytext'

print " "  # FIXME - bug requires this?

@lib, @test = ARGV

if ARGV.size != 2
  STDERR.puts "Usage: ruby ide.rb libname.rb mywinprog.rb"
end

def menu
$debug.puts "Entering menu"
# @mywin.boxme   # FIXME - dumb hack
  @mywin.clear
  @mywin.puts
  @mywin.puts " World's Simplest Ruby IDE\n "
  @mywin.puts " Lib  = #{@lib}"
  @mywin.puts " Test = #{@test}"
  @mywin.puts 
  @mywin.puts " 1  Edit lib"
  @mywin.puts " 2  Edit test"
  @mywin.puts " 3  Run test"
  @mywin.puts " 4  pry"
  @mywin.puts " 5  Shell"
  @mywin.puts " 6  irb"
  @mywin.puts " 7  RubyDocs"
  @mywin.puts
  @mywin.puts " 0  Quit"
  @mywin.print "\n  Choice = "
  @mywin.refresh   # FIXME - dumb hack
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
$debug.puts "about to call getch"
  cmd = getch.chr
$debug.puts "called getch - '#{cmd}'"
  case cmd
    when "1"; system("vi #{@lib}")
    when "2"; system("vi #{@test}") 
    when "3"; system("ruby #{@test}")
    when "4"; shell("pry")
    when "5"; shell("bash")
    when "6"; shell("irb")
    when "7"; system("open -a Safari http://ruby-doc.org")
    when "0"; exit
    else 
      @mywin.rcprint 12, 4, "\n\n  No such command '#{cmd}'"
      sleep 1
      next
  end
end

