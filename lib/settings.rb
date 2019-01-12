module RubyText
  # Hmm, all these are module-level...?

  ValidArgs = [:raw, :_raw, :echo, :_echo, :cbreak, :_cbreak, 
               :keypad, :_keypad, :cursor, :_cursor]


  class Settings
    # raw echo cbreak keypad cursor
    def initialize
      @defaults = {raw: false, echo: false, cbreak: true, keypad: true, cursor: true}
      @current = @defaults.dup
      @stack = []
      @stack.push @current   # Note: Never let stack be empty
      set_curses(@current)   # Set them for real
      # FIXME To be continued...
    end

    def set_curses(**hash)
      # Later: check for bad keys
      hash.each_pair do |sym, val|
        case [sym, val]
          when [:cbreak, true];  Curses.cbreak
          when [:cbreak, false]; Curses.nocbreak
          when [:raw, true];     Curses.raw
          when [:raw, false];    Curses.noraw
          when [:echo, true];    Curses.echo
          when [:echo, false];   Curses.noecho
          when [:keypad, true];  STDSCR.cwin.keypad(true)
          when [:keypad, false]; STDSCR.cwin.keypad(false)
          when [:cursor, true];  Curses.curs_set(1)
          when [:cursor, false]; Curses.curs_set(0)
        end
      end
    end
    
    def set_boolean(raw: nil, echo: nil, cbreak: nil, keypad: nil, cursor: nil)
      raw    ||= @current[:raw]
      echo   ||= @current[:echo]
      cbreak ||= @current[:cbreak]
      keypad ||= @current[:keypad]
      cursor ||= @current[:cursor]
      @stack.push @current
      @current = {raw: raw, echo: echo, cbreak: cbreak, keypad: keypad, cursor: cursor}
      set_curses(@current)
    end

    def reset_boolean
      @current = @stack.pop rescue @stack[0]
      set_curses(@current)
    end

    def set(syms)
      # FIXME - call set_boolean
      # allow a block here?
    end

    def reset
      # FIXME - call reset_boolean
    end
  end

  def self.started   # remove later
    @started
  end

  def self.started?
    @started
  end

  def self.beep
    Curses.beep
  end

  def self.flash
    Curses.flash
  end

  $debugging = true

  # FIXME refactor save/restore, etc.  - rep as binary vector?

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
    self.set(:_echo, :cbreak, :keypad)  # defaults
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

# FIXME Refactor the Hal out of this...

    def self.inverse_flag(flag)
      sflag = flag.to_s
      if sflag[0] == "_"
        sflag[1..-1].to_sym
      else
        ("_" + sflag).to_sym
      end
    end

    def self.set(*args)   # Allow a block?
      standard = [:cbreak, :raw, :echo]
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
          Curses.send(flag)
        elsif flag[0] == "_" && standard.include?(flag[1..-1].to_sym)
          flag.sub!(/^_/, "no")
          Curses.send(flag)
        else
          case flag.to_sym
            when :cursor
              Curses.curs_set(1)
            when :_cursor, :nocursor
              Curses.curs_set(0)
            when :keypad
              STDSCR.cwin.keypad(true)
            when :_keypad
              STDSCR.cwin.keypad(false)
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
      self.set(*@flags)
    rescue 
      @flags = @defaults
    end

# ... end of ugly settings weirdness

  def self.stop
    @started = false
    Curses.close_screen
  end

  # For passing through arbitrary method calls
  # to the lower level...

  def self.method_missing(name, *args)
    debug "method_missing: #{name}  #{args.inspect}"
    if name[0] == '_'
      Curses.send(name[1..-1], *args)
    else
      raise "#{name} #{args.inspect}" # NoMethodError
    end
  end

  def self.hide_cursor    # remove later?
    Curses.curs_set(0)
  end

  def self.show_cursor    # remove later?
    Curses.curs_set(1)
  end

  def self.show_cursor!
    Curses.curs_set(2)  # Doesn't work? Device-dependent?
  end
end

