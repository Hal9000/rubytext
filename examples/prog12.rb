win = RubyText.window(12, 65, 1, 5, true, fg: :black, bg: :blue)

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
