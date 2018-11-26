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
