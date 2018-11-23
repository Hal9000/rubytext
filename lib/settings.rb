module RubyText
  def self.set(*args)
    # Allow a block?
    standard = [:cbreak, :raw, :echo, :keypad]
    @flags = []   # FIXME can set/reset individually. hmmm
    args.each do |arg|
      if standard.include? arg
        flag = arg.to_s
        @flags << arg
        flag.sub!(/_/, "no")
        X.send(flag)
      else
        @flags << arg
        case arg
          when :cursor
            X.show_cursor
          when :_cursor, :nocursor
            X.hide_cursor
        end
      end
    end
  end

  def save_flags
    @fstack ||= []
    @fstack.push @flags
  end

  def rest_flags
    @flags = @fstack.pop
  end

  def self.start(*args, log: nil, fg: nil, bg: nil)
    $debug = File.new(log, "w") if log
    Object.const_set(:STDSCR, RubyText::Window.main(fg: fg, bg: bg))
    $stdscr = STDSCR
    fg, bg, cp = fb2cp(fg, bg)
    self.set(:_echo, :cbreak, :raw)  # defaults
#   X.stdscr.keypad(true)
    self.set(*args)  # override defaults
  end

  # For passing through arbitrary method calls
  # to the lower level...

  def self.method_missing(name, *args)
    debug "method_missing: #{name}  #{args.inspect}"
    if name[0] == '_'
      X.send(name[1..-1], *args)
    else
      raise "#{name} #{args.inspect}" # NoMethodError
    end
  end

  def RubyText.window(high, wide, r0, c0, border=false, fg: nil, bg: nil)
    RubyText::Window.new(high, wide, r0, c0, border, fg, bg)
  end

  def self.hide_cursor
    X.curs_set(0)
  end

  def self.show_cursor
    X.curs_set(1)
  end

  def self.show_cursor!
    X.curs_set(2)  # Doesn't work?
  end
end

