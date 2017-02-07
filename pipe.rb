class Pipe

  def initialize(width, height)
    @x = width
    @space = random_space(height)
  end

  def x
    @x
  end

  def pos
    [@x - 1, @space - 3, @space + 1]
  end

  def random_space(height)
    [*3..height-2].sample
  end

  def update
    @x -= 1 if @x >= 0
  end
end
