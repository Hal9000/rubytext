module RubyText
  def self.set(*args)   # Allow a block?
    standard = [:cbreak, :raw, :echo, :keypad]
    @defaults = [:cbreak, :echo, :keypad, :cursor]
    @flags = @defaults.dup
    save_flags
    args.each do |arg|
      @flags << arg
      flag = arg.to_s
      if standard.include? flag.to_sym
        X.send(flag)
      elsif flag[0] == "_" && standard.include?(flag[1..-1].to_sym)
        flag.sub!(/^_/, "no")
        X.send(flag)
      else
        case arg
          when :cursor
            X.show_cursor
          when :_cursor, :nocursor
            X.hide_cursor
          else puts "wtf is #{arg}?"
        end
      end
    end
    if block_given?
      yield
      rest_flags
    end
  end

  def self.reset
    restflags
  end

  def self.save_flags
    @fstack ||= []
    @fstack.push @flags
  end

  def self.rest_flags
    @flags = @fstack.pop
  rescue 
    @flags = @defaults
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

