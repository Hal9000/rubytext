$LOAD_PATH << "."

require "minitest/autorun"

require 'rubytext'

at_exit { RubyText.stop }

class MyTest < Minitest::Test

  def setup
    load "rubytext.rb"
  end

  def show_lines(text)
    lines = text.split("\n")
    str = "#{lines.size} lines\n"
    lines.each {|line| str << "  #{line.inspect}\n" }
    str
  end

  def test_001_start_no_params
    RubyText.start
    curr = RubyText.flags
    RubyText.stop
    assert curr == [:cbreak, :_echo, :keypad], "Got #{curr.inspect}"
  rescue
    RubyText.stop
  end

  def test_002_start_bad_param
    assert_raises(RTError) { RubyText.start(:foobar); RubyText.stop }
  rescue
    RubyText.stop
  end

  def test_003_start_bad_color
    assert_raises(RTError) { RubyText.start(fg: :chartreuse); RubyText.stop }
  rescue
    RubyText.stop
  end

  def test_004_set_reset
    RubyText.start
    orig = [:cbreak, :_echo, :keypad]
    assert RubyText.flags == orig

    used = [:raw, :_cursor, :_echo]
    RubyText.set(*used)
    curr = RubyText.flags
    assert used.all? {|x| curr.include? x }, "Got #{curr.inspect}"

    RubyText.reset
    assert RubyText.flags == orig

    RubyText.stop
  rescue
    RubyText.stop
  end

  def test_005_set_block
    RubyText.start
    orig = RubyText.flags
    used = [:raw, :_cursor, :_echo]
    RubyText.set(*used) do 
      curr = RubyText.flags
      assert used.all? {|x| curr.include? x }
    end
    # outside block again...
    assert RubyText.flags == orig

    RubyText.stop
  rescue
    RubyText.stop
  end

end

