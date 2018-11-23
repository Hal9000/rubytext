module RubyText

  def self.saveback(high, wide, r, c)
    @pos = STDSCR.rc
    @save = []
    0.upto(high) do |h|
      0.upto(wide) do |w|
        @save << STDSCR[h+r, w+c]
      end
    end
  end

  def self.restback(high, wide, r, c)
    0.upto(high) do |h|
      0.upto(wide) do |w|
        STDSCR[h+r, w+c] = @save.shift
      end
    end
    STDSCR.go *@pos
    STDSCR.refresh
  end

  def self.menu(r: 0, c: 0, items:)
    high = items.size + 2
    wide = items.map(&:length).max + 4
    saveback(high, wide, r, c)
    @mywin = RubyText.window(high, wide, r, c, true, fg: :white, bg: :blue)
    RubyText.set(:raw)
    X.stdscr.keypad(true)
    RubyText.hide_cursor
    sel = 0
    max = items.size - 1
    loop do
      items.each.with_index do |item, row|
        @mywin.go row, 0
        color = sel == row ? :yellow : :white
        @mywin.puts color, " #{item} "
      end
      ch = getch
      case ch
        when X::KEY_UP
          sel -= 1 if sel > 0
        when X::KEY_DOWN
          sel += 1 if sel < max
        when 27
          restback(high, wide, r, c)
          return nil
        when 10
          restback(high, wide, r, c)
          return sel
      end
    end
  end

  def selector(r: 0, c: 0, rows: 10, cols: 20, items:, 
               win:, callback:, quit: "q")
    high = rows
    wide = cols
    saveback(high, wide, r, c)
    menu_win = RubyText.window(high, wide, r, c, true, fg: :white, bg: :blue)
    win2 = win
    handler = callback
    RubyText.set(:raw)
    X.stdscr.keypad(true)
    RubyText.hide_cursor
    sel = 0
    max = items.size - 1
    handler.call(0, items[0])
    loop do
      items.each.with_index do |item, row|
        menu_win.go row, 0
        color = sel == row ? :yellow : :white
        menu_win.puts color, " #{item} "
      end
      ch = getch
      case ch
        when X::KEY_UP
          if sel > 0
            sel -= 1
            handler.call(sel, items[sel])
          end
        when X::KEY_DOWN
          if sel < max
            sel += 1
            handler.call(sel, items[sel])
          end
        when quit  # parameter
          win2.clear
          win2.puts "About to quit..."
          sleep 1
          exit
      end
    end
  end
end

