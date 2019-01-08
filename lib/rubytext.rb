$LOAD_PATH << "lib"

require 'curses'

module RubyText
end

require 'rubytext_version'
require 'output'       # RubyText, RubyText::Window, Kernel
require 'keys'         # RubyText::Keys
require 'menu'         # RubyText
require 'window'       # RubyText::Window
require 'color'        # RubyText, RubyText::Window
require 'effects'
require 'navigation'   # RubyText::Window
require 'settings'     # RubyText
require 'widgets'


# Skeleton... Can't put classes at top because of #initalize

module RubyText
  module Keys
  end

  class Window
  end
end

##########

at_exit { RubyText.stop }

# FIXME lots of changes to make here...

def import(meth, recv)
  Kernel.module_eval do
    define_method(meth) {|*args| recv.send(meth, *args) }
  end
end

def make_exception(sym, str)   # FIXME refactor
  return if Object.constants.include?(sym)
  Object.const_set(sym, StandardError.dup)
  define_method(sym) do |*args|
    msg = str
    list = (args + [nil]*2)[0..2]
    list.each.with_index {|arg, i| msg.sub!("$#{i+1}", arg.to_s) }
    Object.class_eval(sym.to_s).new(msg)
  end
end

make_exception(:RTError, "General error: $1 $2 $3")
   # TODO more...

def debugging(onoff)
  $debugging = onoff    # FIXME eschew global?
end

def debug(*args)
  return unless $debugging
  return unless $debug   # FIXME eschew global?
  $debug.puts *args
  $debug.flush
end

