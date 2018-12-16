puts "\n\n\n putch can take optional row/column keyword arguments"
puts " as well as 'fx' (text effects)"

STDSCR.go 1, 60;   sleep 0.4
STDSCR.putch "0";  sleep 0.4

STDSCR.putch '1', r: 3,  c: 64,  fx: RubyText::Effects.new(Red);               sleep 0.4 
STDSCR.putch '2', r: 5,  c: 68, fx: RubyText::Effects.new(Yellow, :reverse);   sleep 0.4 
STDSCR.putch '3', r: 7,  c: 72;                                                sleep 0.4 
STDSCR.putch '4', r: 9,  c: 76, fx: RubyText::Effects.new(Green, :normal);     sleep 0.4 
STDSCR.putch '5', r: 11, c: 80, fx: RubyText::Effects.new(Red, :normal)

STDSCR.home
