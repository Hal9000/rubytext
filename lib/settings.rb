module RubyText
  # Hmm, all these are module-level...?

  class Settings
    ValidArgs = [:raw, :_raw, :echo, :_echo, :cbreak, :_cbreak, 
                 :keypad, :_keypad, :cursor, :_cursor]
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
          when [:keypad, true];  Curses.stdscr.keypad(true)
          when [:keypad, false]; Curses.stdscr.keypad(false)
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

    def set(*syms)
File.open("/tmp/dammit1", "w") {|f| f.puts "-- set: syms = #{syms.inspect}" }
      raise ArgumentError unless syms - ValidArgs == []
      # FIXME - call set_boolean
      list = {}
      syms.each do |sym|
        str = sym.to_s
        val = str[0] != "_"
        sym0 = val ? sym : str[1..-1].to_sym
        list[sym0] = val
      end
File.open("/tmp/dammit2", "w") {|f| f.puts "-- list = #{list.inspect}" }
      set_boolean(list)
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
#   $debug ||= File.new(log, "w") if log   # FIXME remove global

    args.each {|arg| raise "#{arg} is not valid" unless Settings::ValidArgs.include?(arg) }
    raise RTError("#{fg} is not a color") unless ::Colors.include? fg
    raise RTError("#{bg} is not a color") unless ::Colors.include? bg

    @settings = Settings.new
    @settings.set(*args)            # override defaults

    main = RubyText::Window.main(fg: fg, bg: bg, scroll: scroll)
    Object.const_set(:STDSCR, main) unless defined? STDSCR
    $stdscr = STDSCR  # FIXME global needed?
    Object.include(WindowIO)
    @started = true
# rescue => err
#   puts(err.inspect)
#   puts(err.backtrace)
#   raise RTError("#{err}")
  end

  def self.stop
    @started = false
    Curses.close_screen
  end

  def set(*args)
    @settings.set(*args)
  end

  def reset
    @settings.reset
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

