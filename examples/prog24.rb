puts "\n\n\n putch can take optional row/column keyword arguments"
puts " as well as 'fx' (text effects)"

STDSCR.go 1, 55;   sleep 0.4
STDSCR.putch "0";  sleep 0.4

STDSCR.putch '1', r: 3,  c: 59,  fx: RubyText::Effects.new(Red);               sleep 0.4 
STDSCR.putch '2', r: 5,  c: 63, fx: RubyText::Effects.new(Yellow, :reverse);   sleep 0.4 
STDSCR.putch '3', r: 7,  c: 67;                                                sleep 0.4 
STDSCR.putch '4', r: 9,  c: 71, fx: RubyText::Effects.new(Green, :normal);     sleep 0.4 
STDSCR.putch '5', r: 11, c: 75, fx: RubyText::Effects.new(Red, :normal)

STDSCR.home
