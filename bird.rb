class Bird

  @@x = 3

  def initialize(height)
    @height = height
    @tap_count = 0
    @angle = 0
    @y = height/2
    @live = true
  end

  def tap
    @tap_count += 1 if @live
  end

  def ground?
    @height <= @y + 1
  end

  def angle
    @angle
  end

  def x
    @@x
  end

  def y
    @y
  end

  def pos
    {
      :x => x,
      :y => y
    }
  end

  def kill
    @live = false
  end

  def live?
    @live
  end

  def update
    if @tap_count > 0
      @y -= @tap_count
      @y = 0 if @y < 0
      @angle = -30 * @tap_count
      @angle = -90 if @angle < -90
      @tap_count = 0
    elsif @tap_count == 0
      @y += live? ? 1 : 2
      @angle += 30
      @angle = 90 if @angle > 90
    end

    if ground?
      @y = @height - 1
      kill
    end
  end
end
