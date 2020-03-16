# Reopening: Coordinate handling (1-based!)

class RubyText::Window

  # Handle special coordinate names (symbols)

  def coords(r, c)
    r = case
          when r == :center
            self.rows / 2 
          when r == :top
            0
          when r == :bottom
            self.rows - 1
          else
            r
          end
    c = case
          when c == :center
            self.cols / 2 
          when c == :left
            0
          when c == :right
            self.cols - 1
          else
            c
          end
    [r, c]
  end

  # Go to specified row/column in current window

  def goto(r, c)  # only accepts numbers!
    @cwin.setpos(r, c)
    @cwin.refresh
  end


  # Go to specified row/column in current window,
  #   execute block, and return cursor

  def go(r0, c0)
    r, c = coords(r0, c0)
    save = self.rc
    goto r, c 
    if block_given?
      yield 
      goto *save
    end
  end

  # Move cursor up

  def up(n=1)
    r, c = rc
    go r-n, c
  end

  # Move cursor down

  def down(n=1)
    r, c = rc
    go r+n, c
  end

  # Move cursor left

  def left(n=1)
    r, c = rc
    go r, c-n
  end

  # Move cursor right

  def right(n=1)
    r, c = rc
    go r, c+n
  end

  # Move cursor to top of window

  def top
    r, c = rc
    go 0, c
  end

  # Move cursor to bottom of window

  def bottom 
    r, c = rc
    rmax = self.rows - 1
    go rmax, c
  end

  # Move cursor to top of window

  def up!
    top
  end

  # Move cursor to bottom of window

  def down!
    bottom
  end

  # Move cursor to far left of window

  def left!
    r, c = rc
    go r, 0
  end

  # Move cursor to far left of window

  def right!
    r, c = rc
    cmax = self.cols - 1
    go r, cmax
  end

  # Move cursor to home (upper left)

  def home
    go 0, 0
  end

  # Return current row/column

  def rc
    [@cwin.cury, @cwin.curx]
  end
end
