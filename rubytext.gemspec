require 'date'
require 'find'

$LOAD_PATH << "lib"

require "rubytext_version"

Gem::Specification.new do |s|
  system("rm -f *.gem")
  s.name        = 'rubytext'
  s.version     = RubyText::VERSION
  s.date        = Date.today.strftime("%Y-%m-%d")
  s.summary     = "A thick wrapper for Curses"
  s.description = "Uses the curses gem and extends functionality and ease of use in Ruby."
  s.authors     = ["Hal Fulton"]
  s.email       = 'rubyhacker@gmail.com'
  s.executables << "rubytext"
  s.add_runtime_dependency 'curses', "~> 1.3.2"  # , ">= 1.3.2"
  # NOTE: curses 1.4.3 does not cooperate for reasons as yet unknown

  # Files...
  main = Find.find("lib").to_a
  bin  = Find.find("bin").to_a
  ex   = Find.find("examples").to_a
  misc = %w[./README.md ./rubytext.gemspec]
  test = Find.find("test").to_a
  tut  = Find.find("tutorial").to_a

  s.files       =  main + bin + ex + misc + test + tut
  s.homepage    = 'https://github.com/Hal9000/rubytext'
  s.license     = "Ruby"
end
