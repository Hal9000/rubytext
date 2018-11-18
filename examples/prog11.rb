win = RubyText.window(6, 30, 2, 5, true, fg: :black, bg: :blue)

win.puts "We default to cbreak mode, so that characters are "
win.puts "accepted instantly, but control-C still works."
sleep 2
win.puts "\nIf we set raw mode, control-C is disallowed."

RubyText.set(:raw)

win.puts "\nGo ahead, type a ^C."
sleep 5

win.puts "\nI'm still here."
RubyText.set(:_raw)
