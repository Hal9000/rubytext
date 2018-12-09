module RubyText
  # Hmm, all these are module-level.

  ValidArgs = [:raw, :_raw, :echo, :_echo, :cbreak, :_cbreak]

  def self.started
    @started
  end

  def self.start(*args, log: "/tmp/rubytext.log", 
                 fg: White, bg: Blue, scroll: false)
    $debug ||= File.new(log, "w") if log   # FIXME remove global

    args.each {|arg| raise "#{arg} is not valid" unless ValidArgs.include?(arg) }
    raise "#{fg} is not a color" unless ::Colors.include? fg
    raise "#{bg} is not a color" unless ::Colors.include? bg

    main = RubyText::Window.main(fg: fg, bg: bg, scroll: scroll)
    Object.const_set(:STDSCR, main) unless defined? STDSCR
    $stdscr = STDSCR  # FIXME global needed?
    Object.include(WindowIO)
    self.set(:_echo, :cbreak)  # defaults  (:keypad?)
    self.set(*args)            # override defaults
    @started = true
  rescue => err
    debug(err.inspect)
    debug(err.backtrace)
    raise RTError("#{err}")
  end

  def self.flags
    @flags.uniq!
    @flags
  end

# FIXME Refactor the Hal out of this.

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
    @defaults = [:cbreak, :_echo, :keypad]
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
            # self.stop
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

  def self.stop
    @started = false
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

  def self.window(high, wide, r0, c0, border: true, fg: White, bg: Blue, scroll: false)
    RubyText::Window.new(high, wide, r0, c0, border, fg, bg, scroll)
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

