require 'rubytext'

RubyText.start(fg: White, bg: Black)

print " "*10 
Colors.each {|col| print "%-8s" % col.to_s.capitalize }
puts
puts 

Colors.each do |col|
  puts " " + col.to_s.capitalize
  puts
end

STDSCR.bottom

r0 = 2
Colors.each do |fg|
  c0 = 10
  Colors.each do |bg|
    win = RubyText.window(1, 7, r0, c0, 
                          border: false, 
                          fg: fg, bg: bg)
    win.puts " TEXT  "
    c0 += 8
  end
  r0 += 2
end

getch

