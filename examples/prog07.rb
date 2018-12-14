win = RubyText.window(10, 50, r: 2, c: 15, fg: Yellow, bg: Blue)

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

