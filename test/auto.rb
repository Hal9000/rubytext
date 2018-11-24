$LOAD_PATH << "."

require "minitest/autorun"

require 'rubytext'

class MyTest < Minitest::Test

  def show_lines(text)
    lines = text.split("\n")
    str = "#{lines.size} lines\n"
    lines.each {|line| str << "  #{line.inspect}\n" }
    str
  end

  def test_001_start_no_params
    RubyText.start
#   puts RubyText.flags.inspect
    curr = RubyText.flags
    RubyText.stop
    assert curr == [:cbreak, :echo, :keypad, :cursor, :_raw]
  end

  def test_002_start_bad_param
    assert_raises(RTError) { RubyText.start(:foobar); RubyText.stop }
  end

  def test_003_start_bad_color
    assert_raises(RTError) { RubyText.start(fg: :chartreuse); RubyText.stop }
  end

end

