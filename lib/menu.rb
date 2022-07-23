#### FIXME LATER

# The top-level module

module RubyText

  # Wrapper for a curses window

  class Window

    class Menu2D

      class Vertical
        attr_reader :widest, :height, :header, :hash
        def initialize(vlist)
          @header = vlist[0]
          @hash = vlist[1]
          @widest = @header.length
          @hash.each_pair {|k,v| puts "k = #{k.inspect}"; getch; @widest = [@widest, k.length].max }
          @height = @hash.size
        end
      end

      def initialize(win:, r: :center, c: :center, items:, colrow: [0, 0], 
                     border: true, title: nil, fg: Green, bg: Black)
        @win = win
        @list = []
        @header = @list.map {|x| x.header }
        items.each {|vlist| @list << Vertical.new(vlist) }
        @highest = @list.map {|x| x.height }.max
        @full_width = @list.inject(0) {|sum, vlist| sum += vlist.widest + 2 }
        @nlists = items.size
        @grid = Array.new(@nlists)  # column major order
        @grid.map! {|x| [" "] * @highest }
        @list.each.with_index do |vlist, i|  
          vlist.hash.each_pair.with_index do |kv, j|
            k, v = kv
            @grid[i][j] = [k, v]
          end
        end
        RubyText.hide_cursor
        @high = @highest
        @wide = @full_width
        @high += 2 if border
        @wide += 2 if border

        tlen = title.length + 8 rescue 0
        # wide = [wide, tlen].max
        row, col = @win.coords(r, c)
        row = row - @high/2 if r == :center
        col = col - @wide/2 if c == :center
        r, c = row, col
        @win.saveback(@high+1, @wide, r, c)
        mr, mc = r+@win.r0, c+@win.c0
        title = nil unless border

        @mwin = RubyText.window(@high+1, @wide, r: mr, c: mc, border: true,
                                fg: fg, bg: bg, title: title)
        @header.each {|head| printf "%-#{maxw}s", head }
        puts  # after header
        Curses.stdscr.keypad(true)
        maxcol = items.size - 1
        sizes = items.map {|x| x.size }
        max = sizes.max
        # mwin.go(r, c)
        r += 1   # account for header
        @selc, @selr = colrow
      end

      def show(r, c, colrow: [0, 0])
        @selc, @selr = colrow
        @grid.each.with_index do |column, cix|
          column.each.with_index do |pairs, rix|   # {Jan: ..., Feb: ..., Mar: ..., ...}
            # STDSCR.puts "go: #{r}+#{rix}, #{c}+#{cix}*#{maxw}"
            @mwin.go(rix, cix)  # FIXME wrong?
            style = ([@selc, @selr] == [cix, rix]) ? :reverse : :normal
            key, val = pairs
            label = key.to_s
            @mwin.print label # fx(label, style)
          end
        end
      end

      def handle(r, c)
        loop do
          show(r, c)
          ch = getch
          case ch
            when RubyText::Window::Up
              @selr -= 1 if @selr > 0
            when RubyText::Window::Down
#             puts "PAUSE r,c = #@selr #@selc  highest=#@highest"; getch
              @selr += 1 if @selr < @highest - 1
            when RubyText::Window::Left
              @selc -= 1 if @selc > 0
            when RubyText::Window::Right
              @selc += 1 if @selc < @full_width
            when RubyText::Window::Esc
              @win.restback(@high+1, @wide, r-1, c)
              RubyText.show_cursor
              return [nil, nil, nil]
            when RubyText::Window::Enter
              @win.restback(@high+1, @wide, r-1, c)
              RubyText.show_cursor
              choice = @grid[@selc][@selr][1]
              case choice
                when String;   
                     puts "Returning #{[@selc, @selr, choice].inspect}"; getch
                     return [@selc, @selr, choice]
                when NilClass; return [nil, nil, nil]
              end
              result = choice.call   # should be a Proc
              return [nil, nil, nil] if result.nil? || result.empty?
              return result
            else Curses.beep
          end
        end
        RubyText.show_cursor
      end
    end


    def rectmenu(r: :center, c: :center, items:, colrow: [0, 0], 
                 border: true,
                 title: nil, fg: Green, bg: Black)
      RubyText.hide_cursor
      maxh, maxw = _rectmenu_maxes(items)
      header, stuff = _rect_hash2array(items, maxh, maxw)
      wide = items.size * maxw
      high = maxh
      high += 2 if border
      wide += 2 if border

      tlen = title.length + 8 rescue 0
      # wide = [wide, tlen].max
      row, col = @win.coords(r, c)
      row = row - high/2 if r == :center
      col = col - wide/2 if c == :center
      r, c = row, col
      @win.saveback(high+1, wide, r, c)
      mr, mc = r+@win.r0, c+@win.c0
      title = nil unless border

      mwin = RubyText.window(high+1, wide, r: mr, c: mc, border: true,
                             fg: fg, bg: bg, title: title)
      header.each {|head| printf "%-#{maxw}s", head }
      puts  # after header
      Curses.stdscr.keypad(true)
      maxcol = items.size - 1
      sizes = items.map {|x| x.size }
      max = sizes.max
      # mwin.go(r, c)
      r += 1   # account for header
      selc, selr = colrow

      loop do
        RubyText.hide_cursor  # FIXME should be unnecessary
        stuff.each.with_index do |column, cix|
          column.each.with_index do |pairs, rix|   # {Jan: ..., Feb: ..., Mar: ..., ...}
            STDSCR.puts "go: #{r}+#{rix}, #{c}+#{cix}*#{maxw}"
            mwin.go(rix+1, cix*maxw)
            style = ([selc, selr] == [cix, rix]) ? :reverse : :normal
            key, val = pairs
            label = key.to_s
#           mwin.print fx(label, style)
            mwin.print label # fx(label, style)
          end
        end
        ch = getch
        case ch
          when Up
            selr -= 1 if selr > 0
          when Down
            selr += 1 if selr < maxh - 1
          when Left
            selc -= 1 if selc > 0
          when Right
            selc += 1 if selc < maxcol
          when Esc
            self.restback(high+1, wide, r-1, c)
            RubyText.show_cursor
            return [nil, nil, nil]
          when Enter
            self.restback(high+1, wide, r-1, c)
            RubyText.show_cursor
            choice = stuff[selc][selr][1]
            case choice
              when String;   return [selc, selr, choice]
              when NilClass; return [nil, nil, nil]
            end
            result = choice.call   # should be a Proc
            return [nil, nil, nil] if result.nil? || result.empty?
            return result
          else Curses.beep
        end
        RubyText.show_cursor
      end
    end
  end
end

module RubyText

  # Two-paned widget with menu on left, informtional area on right

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

  # "Menu" for checklists

    def checklist(r: :center, c: :center, 
                  items:, curr: 0, selected: [],
                  title: nil, sel_fg: Yellow, fg: White, bg: Blue)
      RubyText.hide_cursor
      high = items.size + 2
      wide = items.map(&:length).max + 8
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
          color = selected.find {|x| x[0] == row } ? sel_fg : fg
          label = "[ ]" + item
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
            selected << [sel, items[sel]]
            sel += 1 if sel < max
        else Curses.beep
        end
        RubyText.show_cursor
      end
    end

end

# The top-level module

module RubyText

  # Wrapper for a curses window

  class Window

    # One-line menu at top of window

    def topmenu(items:, curr: 0, fg: Green, bg: Black)
      r, c, high = 0, 0, 1
      RubyText.hide_cursor
      hash_flag = false
      results = items
      if items.is_a?(Hash)
        results, items = items.values, items.keys
        hash_flag = true
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
            STDSCR.go r, c
            return [nil, nil]
          when Down, Enter
            self.restback(high, width, r, c)
            RubyText.show_cursor
            STDSCR.go r, c
            choice = results[sel]
            return [sel, choice] if choice.is_a? String
            result = choice.call
            return [nil, nil, nil] if result.nil? || result.empty?
#           next if result.nil?
#           next if result.empty?
#           return result
        else Curses.beep
        end
        RubyText.show_cursor
      end
    end

    # Simple menu with rows of strings (or Procs)

    def menu(r: :center, c: :center, items:, curr: 0, 
             border: true, sticky: false,
             title: nil, fg: Green, bg: Black, wrap: false)
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
            if sel > 0
              sel -= 1 
            else
              sel = max if wrap  # asteroids mode :)
            end
          when Down, " "  # let space mean down?
            if sel < max
              sel += 1 
            else
              sel = 0 if wrap    # asteroids mode :)
            end
          when Esc
            self.restback(high, wide, r, c)
            RubyText.show_cursor
            return [nil, nil]
          when Enter
            self.restback(high, wide, r, c) unless sticky
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

    # Menu for multiple selections (buggy/unused?)

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

    # Simple yes/no decision

    def yesno
      # TODO: Accept YyNn
      r, c = STDSCR.rc
      num, str = STDSCR.menu(r: r, c: c+6, items: ["yes", "no"])
      num == 0
    end

    # Menu to choose a single setting and retain it

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
end

module RubyText

  # Two-paned widget with menu on left, informtional area on right

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

  # "Menu" for checklists

    def checklist(r: :center, c: :center, 
                  items:, curr: 0, selected: [],
                  title: nil, sel_fg: Yellow, fg: White, bg: Blue)
      RubyText.hide_cursor
      high = items.size + 2
      wide = items.map(&:length).max + 8
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
          color = selected.find {|x| x[0] == row } ? sel_fg : fg
          label = "[ ]" + item
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
            selected << [sel, items[sel]]
            sel += 1 if sel < max
        else Curses.beep
        end
        RubyText.show_cursor
      end
    end

end


