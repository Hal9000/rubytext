class RubyText::Window
  def go(r, c)
    save = self.rc
    @win.setpos(r, c)
    if block_given?
      yield
      go(*save)   # No block here!
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

  def crlf
    r, c = rc
    go r+1, 0
  end

  def rc
    [@win.cury, @win.curx]
  end
end
