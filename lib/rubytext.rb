$LOAD_PATH << "lib"

require 'curses'

X = Curses  # shorthand

require 'version'

require 'output'       # RubyText, RubyText::Window, Kernel
require 'keys'         # RubyText::Keys
require 'menu'         # RubyText
require 'window'       # RubyText::Window
require 'color'        # RubyText, RubyText::Window
require 'effects'
require 'navigation'   # RubyText::Window
require 'settings'     # RubyText


# Skeleton... Can't put at top because of #initalize

module RubyText
  module Keys
  end

  class Window
  end
end

def import(meth, recv)
  Kernel.module_eval do
    define_method(meth) {|*args| recv.send(meth, *args) }
  end
end
