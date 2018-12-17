require 'rubytext'

RubyText.start

puts "\n Methods such as go, rcprint, and putch"
puts " can accept symbols such as"
puts " :top :bottom :left :right :center"

win = RubyText.window(7, 25, r: 5, c: 10, fg: Red, bg: Black)

win.putch "1", r: :bottom, c: :left
sleep 0.4
win.go :center, :left
win.puts "abc"
sleep 0.4
win.go :top, :left
win.puts "def"
sleep 0.4
win.rcprint :top, :center, "4"
sleep 0.4

others = [[:top, :right, "5"], [:center, :right, "6"], 
          [:bottom, :right, "7"], [:bottom, :center, "8"], 
          [:center, :center, "9"]] 

others.each do |args| 
  r, c, ch = *args
  win.go r,c
  win.putch(ch)
  sleep 0.4
end

getch
