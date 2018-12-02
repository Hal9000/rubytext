win = RubyText.window(9, 36, 5, 11, fg: White, bg: Red) 

win.output do
  puts "Because this code uses #output,"
  puts "it doesn't have to specify the"
  puts "window as a receiver each time."
end
