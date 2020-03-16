
# Helper method: insert text effects while printing

def fx(str, *args, bg: nil)
  eff = RubyText::Effects.new(*args, bg: bg)
  str.define_singleton_method(:effect) { eff } 
  str  # must return str
end

# Hande text effects (bold, normal, reverse, underline)

class RubyText::Effects   # dumb name?

  # Text modes
  Modes  = {bold:    Curses::A_BOLD,
            normal:  Curses::A_NORMAL,
            reverse: Curses::A_REVERSE, 
            under:   Curses::A_UNDERLINE}

  # Other text modes "of our own"

  Others = %[:show, :hide]  # show/hide cursor; more later??

  attr_reader :value, :fg, :bg

  # @todo rewrite logic to accommodate color pairs

  # Initialize an Effects object
  
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

  # "Turn on" effect to specified window

  def set(win)
    @old_fg, @old_bg  = win.fg, win.bg  # Save off current state?
    attr, fg, bg = self.value, self.fg, self.bg
    win.cwin.attron(attr)
    fg ||= win.fg
    bg ||= win.bg
    win.set_colors(fg, bg)
  end

  # "Turn off" effect in specified window

  def reset(win)
    attr = self.value
    win.cwin.attroff(attr)
    win.set_colors(@old_fg, @old_bg)  # Does restore logic work?
  end
end
