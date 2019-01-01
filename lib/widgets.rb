module RubyText
  def self.ticker(row: STDSCR.rows-1, col: 0, width: STDSCR.cols, 
                  fg: White, bg: Blue, text:, delay: 0.1)
    text = text.gsub("\n", " ") + " "
    win = RubyText.window(1, width, r: row, c: col, border: false, fg: fg, bg: bg)
    leader = " "*width + text
    leader = text.chars.cycle.each_cons(width)
    width.times { win.rcprint 0, 0, leader.next.join }
    repeat = text.chars.cycle.each_cons(width)
    loop do   # Warning: loops forever
      win.rcprint 0, 0, repeat.next.join
      sleep delay
    end
  end

  def self.spinner(label: "", win: STDSCR, &block) # TODO delay, etc.
    chars = "-\\|/"
    RubyText.hide_cursor
    t0 = Time.now.to_i
    thread = Thread.new do
      i=0
      loop do 
        t1 = Time.now.to_i
        elapsed = "0:%02d" % (t1-t0)   # FIXME breaks at 60 sec
        i = (i+1) % 4
        win.print " #{label} #{chars[i]}  #{elapsed}"
        win.left!
        sleep 0.04
      end
    end
    ret = block.call
    win.puts
    Thread.kill(thread)
    RubyText.show_cursor
    ret
  end

  def self.splash(msg)
    lines = msg.split("\n")
    high = lines.size + 2
    wide = lines.map {|x| x.length }.max + 2
    STDSCR.saveback(high, wide, 10, 20)
    win = RubyText.window(high, wide, r: 10, c: 20, fg: White, bg: Red)
    win.puts msg
    getch
    STDSCR.restback(high, wide, 10, 20)
  end

  # TODO add splash
end
