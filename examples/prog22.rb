msg = <<~EOS
 A "ticker" example that actually uses threads. Maybe Curses is not as slow as 
 you thought? PRESS ANY KEY TO EXIT...
EOS

w, h = STDSCR.cols, STDSCR.rows - 1
threads = []

r = RubyText
t1 = -> { r.ticker(text: msg, row: h-8, col: 20, width: w-40, delay: 0.02, fg: Red, bg: Black) }
t2 = -> { r.ticker(text: msg, row: h-6, col: 15, width: w-30, delay: 0.04) }
t3 = -> { r.ticker(text: msg, row: h-4, col: 10, width: w-20, delay: 0.06, fg: Black, bg: Green) }
t4 = -> { r.ticker(text: msg, row: h-2, col:  5, width: w-10, delay: 0.08, bg: Black) }
t5 = -> { r.ticker(text: msg) }  # All defaults -- goes at bottom

threads << Thread.new { t1.call } << Thread.new { t2.call } << Thread.new { t3.call } << 
           Thread.new { t4.call } << Thread.new { t5.call }

threads << Thread.new { getch; exit }   # quitter thread...
threads.each {|t| t.join } 
