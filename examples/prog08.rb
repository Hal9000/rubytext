win = RubyText.window(10, 50, 2, 5, true, fg: :yellow, bg: :blue)

sleep 2
win[2,2] = "X"

sleep 2
win[5,8] = "Y"
