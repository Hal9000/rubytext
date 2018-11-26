module RubyText
  # Hmm, all these are module-level.

  def self.flags
    @flags.uniq!
    @flags
  end

  def self.inverse_flag(flag)
    sflag = flag.to_s
    if sflag[0] == "_"
      sflag[1..-1].to_sym
    else
      ("_" + sflag).to_sym
    end
  end

  def self.set(*args)   # Allow a block?
    standard = [:cbreak, :raw, :echo, :keypad]
    @defaults = [:cbreak, :echo, :keypad, :cursor, :_raw]
    @flags = @defaults.dup
    save_flags
    args.each do |arg|
      @flags += [arg]
      inv = inverse_flag(arg)
      @flags -= [inv]
      @flags.uniq!
      flag = arg.to_s
      if standard.include?(flag.to_sym) || standard.include?(flag.sub(/no/, "_").to_sym)
        X.send(flag)
      elsif flag[0] == "_" && standard.include?(flag[1..-1].to_sym)
        flag.sub!(/^_/, "no")
        X.send(flag)
      else
        case flag.to_sym
          when :cursor
            X.curs_set(1)
          when :_cursor, :nocursor
            X.curs_set(0)
          else 
            self.stop
            rest_flags  # prevent propagating error in test
            raise RTError("flag = #{flag.inspect}")
        end
      end
    end

    if block_given?
      yield
      rest_flags
    end
  end

  def self.reset
    rest_flags
  end

  def self.save_flags
    @fstack ||= []
    @flags.uniq!
    @fstack.push @flags
  end

  def self.rest_flags
    @flags = @fstack.pop
    @flags.uniq!
  rescue 
    @flags = @defaults
  end

  def self.start(*args, log: nil, fg: nil, bg: nil)
    $debug = File.new(log, "w") if log
    Object.const_set(:STDSCR, RubyText::Window.main(fg: fg, bg: bg))
    $stdscr = STDSCR
    fg, bg, cp = fb2cp(fg, bg)
    self.set(:_echo, :cbreak, :raw)  # defaults
    self.set(*args)  # override defaults
  rescue => err
    debug(err.inspect)
    debug(err.backtrace)
    raise RTError("#{err}")
  end

  def self.stop
    X.close_screen
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

  def self.window(high, wide, r0, c0, border=false, fg: nil, bg: nil)
    RubyText::Window.new(high, wide, r0, c0, border, fg, bg)
  end

  def self.hide_cursor
    X.curs_set(0)
  end

  def self.show_cursor
    X.curs_set(1)
  end

  def self.show_cursor!
    X.curs_set(2)  # Doesn't work? Device-dependent?
  end
end

