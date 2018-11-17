win = RubyText.window(10, 50, 2, 5, true, fg: :yellow, bg: :blue)

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

