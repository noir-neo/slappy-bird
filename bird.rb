class Bird
  def initialize(height)
    @tap_count = -1
    @altitude = height/2
    @angle = 0
  end

  def tap
    @tap_count += 1
  end

  def altitude
    @altitude
  end

  def angle
    @angle
  end

  def update
    if @tap_count > 0
      @altitude += @tap_count
      @angle = -30 * @tap_count
      @angle = -90 if @angle < -90
      @tap_count = 0
    elsif @tap_count == 0
      @altitude -= 1
      @angle += 30
      @angle = 90 if @angle > 90
    end

    if @altitude < 1
      @altitude = 0
    end
  end
end
