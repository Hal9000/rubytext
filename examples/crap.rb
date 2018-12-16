require 'rubytext'

RubyText.start

STDSCR.go 1, 2
STDSCR.putch "0"

STDSCR.putch '1', r: 3,  c: 6,  fx: RubyText::Effects.new(Red)
STDSCR.putch '2', r: 5,  c: 10, fx: RubyText::Effects.new(Yellow, :reverse)
STDSCR.putch '3', r: 7,  c: 14
STDSCR.putch '4', r: 9,  c: 18, fx: RubyText::Effects.new(Green, :normal)
STDSCR.putch '5', r: 11, c: 22, fx: RubyText::Effects.new(Red, :normal)

STDSCR.home

getch
