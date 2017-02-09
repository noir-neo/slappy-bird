class Pipe

  @@speed = 1

  def initialize(width, height)
    @x = width
    @space = random_space(height)
  end

  def x
    @x
  end

  def pos
    {
      :x => @x - 1,
      :top => @space - 3,
      :bottom => @space + 1
    }
  end

  def next_pos
    {
      :x => @x - @@speed - 1,
      :top => @space - 3,
      :bottom => @space + 1
    }
  end

  def random_space(height)
    [*3..height-2].sample
  end

  def update
    @x -= @@speed if @x >= 0
  end
end
