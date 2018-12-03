module RubyText

  def self.saveback(high, wide, r, c)
    @pos = STDSCR.rc
    @save = []
    0.upto(high-1) do |h|
      0.upto(wide-1) do |w|
        @save << STDSCR[h+r, w+c]
      end
    end
  end

  def self.restback(high, wide, r, c)
    0.upto(high-1) do |h|
      0.upto(wide-1) do |w|
        STDSCR[h+r, w+c] = @save.shift
      end
    end
    STDSCR.go *@pos
    STDSCR.refresh
  end

  def self.menu(r: 0, c: 0, items:, curr: 0,
                fg: White, bg: Blue)
    high = items.size + 2
    wide = items.map(&:length).max + 4
    saveback(high, wide, r, c)
    win = RubyText.window(high, wide, r, c, fg: fg, bg: bg)
#   RubyText.set(:raw)
    X.stdscr.keypad(true)
    RubyText.hide_cursor
    sel = curr
    max = items.size - 1
    norm = RubyText::Effects.new(win, :normal)
    rev = RubyText::Effects.new(win, :reverse)
    loop do
      items.each.with_index do |item, row|
        win.go row, 0
        style = (sel == row) ? rev : norm
        win.print style, " #{item} "
      end
      ch = getch
      case ch
        when X::KEY_UP
          sel -= 1 if sel > 0
        when X::KEY_DOWN
          sel += 1 if sel < max
        when 27
          restback(high, wide, r, c)
          return [nil, nil]
        when 10
          restback(high, wide, r, c)
          return [sel, items[sel]]
      end
    end
  end

  def self.selector(r: 0, c: 0, rows: 10, cols: 20, 
                    items:, fg: White, bg: Blue,
                    win:, callback:, enter: nil, quit: "q")
    high = rows
    wide = cols
    saveback(high, wide, r, c)
    menu_win = RubyText.window(high, wide, r, c, fg: fg, bg: bg)
    win2 = win
    handler = callback
#   RubyText.set(:raw)
    X.stdscr.keypad(true)
    RubyText.hide_cursor
    norm = RubyText::Effects.new(menu_win, :normal)
    rev  = RubyText::Effects.new(menu_win, :reverse)
    sel = 0
    max = items.size - 1
    send(handler, sel, items[sel], win2)
    loop do
      menu_win.home
      items.each.with_index do |item, row|
        menu_win.left
        style = (sel == row) ? rev : norm
        menu_win.puts style, " #{item} "
      end
      ch = getch
      case ch
        when X::KEY_UP
          if sel > 0
            sel -= 1
            send(handler, sel, items[sel], win2)
          end
        when X::KEY_DOWN
          if sel < max
            sel += 1
            send(handler, sel, items[sel], win2)
          end
        when 10  # Enter
          if enter
            del = send(enter, sel, items[sel], win2)
            if del
              items -= [items[sel]]
              raise 
            end
          end
        when quit  # parameter
          exit
      end
    end
  rescue
    retry
  end
end

