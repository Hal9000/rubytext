

def fx(str, *args, bg: nil)
  eff = RubyText::Effects.new(*args, bg: bg)
  str.define_singleton_method(:effect) { eff } 
  str  # must return str
end

class RubyText::Effects   # dumb name?
  Modes  = {bold:    X::A_BOLD,
            normal:  X::A_NORMAL,
            reverse: X::A_REVERSE, 
            under:   X::A_UNDERLINE}

  Others = %[:show, :hide]  # show/hide cursor; more later??

  attr_reader :value, :fg, :bg

  # TODO rewrite logic to accommodate color pairs
  
  def initialize(*args, bg: nil)
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
    @bg = bg || @bg
    @value = bits
  end

  def set(win)
    @old_fg, @old_bg  = win.fg, win.bg  # Save off current state?
    attr, fg, bg = self.value, self.fg, self.bg
    win.cwin.attron(attr)
    fg ||= win.fg
    bg ||= win.bg
    win.set_colors(fg, bg)
  end

  def reset(win)
    attr = self.value
    win.cwin.attroff(attr)
    win.set_colors(@old_fg, @old_bg)
  end
end

