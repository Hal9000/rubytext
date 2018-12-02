$LOAD_PATH << "lib"

require 'curses'

X = Curses  # shorthand

module RubyText
end

require 'version'
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

def import(meth, recv)
  Kernel.module_eval do
    define_method(meth) {|*args| recv.send(meth, *args) }
  end
end

def make_exception(sym, str)
  return if Object.constants.include?(sym)
  Object.const_set(sym, StandardError.dup)
  define_method(sym) do |*args|
    msg = str
    list = (args + [nil]*2)[0..2]
    list.each.with_index {|arg, i| msg.sub!("$#{i+1}", arg) }
    Object.class_eval(sym.to_s).new(msg)
  end
end

make_exception(:RTError, "General error: $1 $2 $3")

def debug(*args)
  $debug.puts *args
  $debug.flush
end

