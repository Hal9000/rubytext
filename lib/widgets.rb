module RubyText
  def self.ticker(row: STDSCR.rows-1, col: 0, width: STDSCR.cols, 
                  fg: White, bg: Blue, text:, delay: 0.1)
    text = text.gsub("\n", " ") + " "
    win = RubyText.window(1, width, row, col, border: false, fg: fg, bg: bg)
    leader = " "*width + text
    leader = text.chars.cycle.each_cons(width)
    width.times { win.rcprint 0, 0, leader.next.join }
    repeat = text.chars.cycle.each_cons(width)
    loop do   # Warning: loops forever
      win.rcprint 0, 0, repeat.next.join
      sleep delay
    end
  end
end
