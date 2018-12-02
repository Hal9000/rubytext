class RubyText::Effects   # dumb name?
  Modes  = {bold:    X::A_BOLD,
            normal:  X:: A_NORMAL,
            reverse: X:: A_REVERSE, 
            under:   X:: A_UNDERLINE}

  Others = %[:show, :hide]  # show/hide cursor; more later??

  attr_reader :value, :fg
  
  def initialize(win, *args)
    bits = 0
    args.each do |arg|
      if Modes.keys.include?(arg)
        val = Modes[arg]
        bits ||= val
      elsif ::Colors.include?(arg)
        @fg = arg   # symbol
      end
    end
    @value = bits
    X.attrset(bits)
  end
end

