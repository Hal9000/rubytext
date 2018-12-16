class RubyText::Window

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

  def goto(r, c)  # only accepts numbers!
    @cwin.setpos(r, c)
  end

  def go(r0, c0)
    r, c = coords(r0, c0)
    save = self.rc
    goto r, c 
    if block_given?
      yield 
      goto *save
    end
  end

  def up(n=1)
    r, c = rc
    go r-n, c
  end

  def down(n=1)
    r, c = rc
    go r+n, c
  end

  def left(n=1)
    r, c = rc
    go r, c-n
  end

  def right(n=1)
    r, c = rc
    go r, c+n
  end

  def top
    r, c = rc
    go 0, c
  end

  def bottom 
    r, c = rc
    rmax = self.rows - 1
    go rmax, c
  end

  def up!
    top
  end

  def down!
    bottom
  end

  def left!
    r, c = rc
    go r, 0
  end

  def right!
    r, c = rc
    cmax = self.cols - 1
    go r, cmax
  end

  def home
    go 0, 0
  end

  def rc
    [@cwin.cury, @cwin.curx]
  end
end
