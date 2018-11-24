class RubyText::Effects   # dumb name?
  Modes = %w[A_BOLD A_NORMAL A_PROTECT A_REVERSE A_STANDOUT A_UNDERLINE]

  attr_reader :value
  
  def initialize(bg, *args)
    bits = 0
    args.each do |arg|
      if Modes.include?(arg)
        val = eval("X::A_#{arg.to_s.upcase}")
        bits ||= val
      elsif RubyText::Colors.include?(arg)
        val = eval("X::COLOR_#{arg.to_s.upcase}")
        bits ||= val
      end
    end
    @value = bits
    X.attrset(bits)
  end
end

