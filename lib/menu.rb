module RubyText

  def self.menu(win: STDSCR, r: :center, c: :center, items:, curr: 0,
                title: nil, fg: White, bg: Blue)
    RubyText.hide_cursor
    high = items.size + 2
    wide = items.map(&:length).max + 4
    tlen = title.length + 8  
    wide = [wide, tlen].max
    r, c = win.coords(r, c)
    win.saveback(high, wide, r, c)
    mr, mc = r+win.r0, c+win.c0
    debug "menu: rc = #{[r,c].inspect} win r0c0 = #{[win.r0, win.c0].inspect}"
#   debug "   and mr,mc = #{[mr,mc].inspect}"
    mwin = RubyText.window(high, wide, r: mr, c: mc, 
                           fg: fg, bg: bg)

    where = win == STDSCR ? [r, c+1] : [r-1, c+1]  # wtf?

    unless title.nil?
      win.go(*where) do   # same row as corner but farther right
        win.print fx("[ #{title} ]", :bold, fg, bg: bg)
      end
    end

    X.stdscr.keypad(true)
    sel = curr
    max = items.size - 1
    norm = RubyText::Effects.new(:normal)
    rev = RubyText::Effects.new(:reverse)
    loop do
      RubyText.hide_cursor  # FIXME should be unnecessary
      items.each.with_index do |item, row|
        mwin.go row, 0
        style = (sel == row) ? :reverse : :normal
        label = (" "*3 + item + " "*8)[0..wide-1]
        mwin.print fx(label, style)
      end
      ch = getch
      case ch
        when X::KEY_UP
          sel -= 1 if sel > 0
        when X::KEY_DOWN
          sel += 1 if sel < max
        when 27
          win.restback(high, wide, r, c)
          RubyText.show_cursor
          return [nil, nil]
        when 10
          win.restback(high, wide, r, c)
          RubyText.show_cursor
          return [sel, items[sel]]
      end
      RubyText.show_cursor
    end
  end

  def self.selector(win: STDSCR, r: 0, c: 0, rows: 10, cols: 20, 
                    items:, fg: White, bg: Blue,
                    win2:, callback:, enter: nil, quit: "q")
    high = rows
    wide = cols
    mwin = RubyText.indow(high, wide, r: r, c: c, fg: fg, bg: bg)
    handler = callback
    X.stdscr.keypad(true)
    RubyText.hide_cursor
    norm = RubyText::Effects.new(:normal)
    rev  = RubyText::Effects.new(:reverse)
    sel = 0
    max = items.size - 1
    handler.call(sel, items[sel], win2)
    loop do
      mwin.home
      items.each.with_index do |item, row|
        mwin.crlf
        style = (sel == row) ? :reverse : :normal
        mwin.print fx(" #{item}", style)
      end
      ch = getch
      case ch
        when X::KEY_UP
          if sel > 0
            sel -= 1
            handler.call(sel, items[sel], win2)
          end
        when X::KEY_DOWN
          if sel < max
            sel += 1
            handler.call(sel, items[sel], win2)
          end
        when 10  # Enter
          if enter
            del = enter.call(sel, items[sel], win2)
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

