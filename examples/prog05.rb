win = RubyText.window(10, 70, 2, 14, true, fg: :yellow, bg: :black)

win.output do
  puts "Without scrolling, this is what happens when your window fills up..."
  puts "This behavior will probably change later."
  sleep 2
  puts "Let's print 10 more lines now:"
  sleep 2
  
  10.times {|i| puts "Printing line #{i}..."; sleep 0.5 }
end

