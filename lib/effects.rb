

def fx(str, *args)
  eff = RubyText::Effects.new(*args)
  str.define_singleton_method(:effect) { eff } 
  str  # must return str
end

class RubyText::Effects   # dumb name?
  Modes  = {bold:    X::A_BOLD,
            normal:  X::A_NORMAL,
            reverse: X::A_REVERSE, 
            under:   X::A_UNDERLINE}

  Others = %[:show, :hide]  # show/hide cursor; more later??

  attr_reader :value, :fg
  
  def initialize(*args)
    bits = 0
    @list = args
    args.each do |arg|
      if Modes.keys.include?(arg)
        val = Modes[arg]
        bits |= val
      elsif ::Colors.include?(arg)
        @fg = arg   # symbol
      end
    end
    @value = bits
  end

  def set(win)
    # Save off current state?
    @old_fg = win.fg
    attr, fg = self.value, self.fg
    win.cwin.attron(attr)
    win.set_colors(fg, win.bg) if fg
  end

  def reset(win)
    attr = self.value
    win.cwin.attroff(attr)
    win.set_colors(@old_fg, win.bg) if fg
  end
end

