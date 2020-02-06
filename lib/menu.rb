module RubyText

  class Window
    def topmenu(items:, curr: 0, fg: Green, bg: Black)
      r, c = 0, 0
      high = 1

      RubyText.hide_cursor
      if items.is_a?(Hash)
        results = items.values
        items = items.keys
        hash_flag = true
      else
        results = items
      end

      width = 0   # total width
      cols = []   # start-column of each item
      items.each do |item| 
        cols << width
        iwide = item.to_s.length + 2
        width += iwide
      end

      r, c = self.coords(r, c)
      self.saveback(high, width, r, c)
      mr, mc = r+self.r0, c+self.c0
      mwin = RubyText.window(high, width, r: mr, c: mc, fg: fg, bg: bg, border: false, title: nil)
      Curses.stdscr.keypad(true)
      sel = curr
      max = items.size - 1
      loop do
        items.each.with_index do |item, num|
          item = " #{item} "
          mwin.go 0, cols[num]
          style = (sel == num) ? :reverse : :normal
          mwin.print fx(item, style)
        end
        ch = getch
        case ch
          when Left
            sel -= 1 if sel > 0
          when Right
            sel += 1 if sel < max
          when Esc, " "   # spacebar also quits
            self.restback(high, width, r, c)
            RubyText.show_cursor
            return [nil, nil]
          when Down, Enter
            self.restback(high, width, r, c)
            RubyText.show_cursor
            choice = results[sel]
            return [sel, choice] if choice.is_a? String
            result = choice.call
            next if result.nil?
            next if result.empty?
            return result
          else Curses.beep
        end
        RubyText.show_cursor
      end
    end

    def menu(r: :center, c: :center, items:, curr: 0, 
             border: true,
             title: nil, fg: Green, bg: Black)
      RubyText.hide_cursor
      if items.is_a?(Hash)
        results = items.values
        items = items.keys
        hash_flag = true
      else
        results = items
      end
      
      high = items.size
      wide = items.map(&:length).max + 3
      high += 2 if border
      wide += 2 if border

      tlen = title.length + 8 rescue 0
      wide = [wide, tlen].max
      row, col = self.coords(r, c)
      row = row - high/2 if r == :center
      col = col - wide/2 if c == :center
      r, c = row, col
      self.saveback(high, wide, r, c)
      mr, mc = r+self.r0, c+self.c0
      title = nil unless border
      mwin = RubyText.window(high, wide, r: mr, c: mc, border: border,
                             fg: fg, bg: bg, title: title)
      Curses.stdscr.keypad(true)
      sel = curr
      max = items.size - 1
      loop do
        RubyText.hide_cursor  # FIXME should be unnecessary
        items.each.with_index do |item, row|
          mwin.go row, 0
          style = (sel == row) ? :reverse : :normal
          label = (" "*2 + item.to_s + " "*8)[0..wide-1]
          mwin.print fx(label, style)
        end
        ch = getch
        case ch
          when Up
            sel -= 1 if sel > 0
          when Down
            sel += 1 if sel < max
          when Esc
            self.restback(high, wide, r, c)
            RubyText.show_cursor
            return [nil, nil]
          when Enter
            self.restback(high, wide, r, c)
            RubyText.show_cursor
            choice = results[sel]
            return [sel, choice] if choice.is_a? String
            result = choice.call
            return [nil, nil] if result.nil? || result.empty?
            return result
          else Curses.beep
        end
        RubyText.show_cursor
      end
    end

    def multimenu(r: :center, c: :center, 
                  items:, curr: 0, selected: [],
                  title: nil, sel_fg: Yellow, fg: White, bg: Blue)
      RubyText.hide_cursor
      high = items.size + 2
      wide = items.map(&:length).max + 5
      tlen = title.length + 8 rescue 0
      wide = [wide, tlen].max
      row, col = self.coords(r, c)
      row = row - high/2 if r == :center
      col = col - wide/2 if c == :center
      r, c = row, col
      self.saveback(high, wide, r, c)
      mr, mc = r+self.r0, c+self.c0
      mwin = RubyText.window(high, wide, r: mr, c: mc, 
                             fg: fg, bg: bg, title: title)
      Curses.stdscr.keypad(true)
      sel = curr
      max = items.size - 1
      loop do
        RubyText.hide_cursor  # FIXME should be unnecessary
        items.each.with_index do |item, row|
          mwin.go row, 0
          style = (sel == row) ? :reverse : :normal
          color = selected.include?(row) ? sel_fg : fg
          label = (" "*2 + item + " "*8)[0..wide-1]
          mwin.print fx(label, color, style)
        end
        ch = getch
        case ch
          when Up
            sel -= 1 if sel > 0
          when Down
            sel += 1 if sel < max
          when Esc
            self.restback(high, wide, r, c)
            RubyText.show_cursor
            return []
          when Enter
            self.restback(high, wide, r, c)
            RubyText.show_cursor
            return selected.map {|i| items[i] }
          when " "
            selected << sel
            sel += 1 if sel < max
          else Curses.beep
        end
        RubyText.show_cursor
      end
    end

    def yesno
      # TODO: Accept YyNn
      r, c = STDSCR.rc
      num, str = STDSCR.menu(r: r, c: c+6, items: ["yes", "no"])
      num == 0
    end

    def radio_menu(r: :center, c: :center, items:, curr: 0, 
             # Handle current value better?
             border: true,
             title: nil, fg: Green, bg: Black)
      RubyText.hide_cursor
      if items.is_a?(Hash)
        results = items.values
        items = items.keys
        hash_flag = true
      else
        results = items
      end
      
      high = items.size
      wide = items.map(&:length).max + 3
      high += 2 if border
      wide += 2 if border

      tlen = title.length + 8 rescue 0
      wide = [wide, tlen].max
      row, col = self.coords(r, c)
      row = row - high/2 if r == :center
      col = col - wide/2 if c == :center
      r, c = row, col
      self.saveback(high, wide, r, c)
      mr, mc = r+self.r0, c+self.c0
      title = nil unless border
      mwin = RubyText.window(high, wide, r: mr, c: mc, border: border,
                             fg: fg, bg: bg, title: title)
      Curses.stdscr.keypad(true)
      sel = curr
      max = items.size - 1
      loop do
        RubyText.hide_cursor  # FIXME should be unnecessary
        items.each.with_index do |item, row|
          mark = row == curr ? ">" : " "
          mwin.go row, 0
          style = (sel == row) ? :reverse : :normal
          label = "#{mark} #{item}"
          mwin.print fx(label, style)
        end
        ch = getch
        case ch
          when Up
            sel -= 1 if sel > 0
          when Down
            sel += 1 if sel < max
          when Esc
            self.restback(high, wide, r, c)
            RubyText.show_cursor
            return [nil, nil]
          when " "
            mwin[curr, 0] = " "
            mwin[sel, 0] = ">"
            curr = sel
          when Enter
            self.restback(high, wide, r, c)
            RubyText.show_cursor
            choice = results[sel]
            return [sel, choice] if choice.is_a? String
            result = choice.call
            return [nil, nil] if result.nil? || result.empty?
            return result
          else Curses.beep
        end
        RubyText.show_cursor
      end
    end
  end

  def self.selector(win: STDSCR, r: 0, c: 0, rows: 10, cols: 20, 
                    items:, fg: White, bg: Blue,
                    win2:, callback:, enter: nil, quit: "q")
    high = rows
    wide = cols
    mwin = RubyText.window(high, wide, r: r, c: c, fg: fg, bg: bg)
    handler = callback
    Curses.stdscr.keypad(true)
    RubyText.hide_cursor
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
        when Up
          if sel > 0
            sel -= 1
            handler.call(sel, items[sel], win2)
          end
        when Down
          if sel < max
            sel += 1
            handler.call(sel, items[sel], win2)
          end
        when Enter
          if enter
            del = enter.call(sel, items[sel], win2)
            if del
              items -= [items[sel]]
              raise 
            end
          end
        when Tab
          Curses.flash
        when quit  # parameter
          exit
        else Curses.beep    # all else is trash
      end
    end
  rescue
    retry
  end
end

