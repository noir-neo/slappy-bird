require './pipe.rb'

class Map
  @@create_pipe_wait_frame = 5

  def initialize(width, height, bg_kinds)
    @pipes = []
    @width = width
    @height = height
    @bg_kinds = bg_kinds
    @countup_create_pipe = 0
    @background = create_background(@width)
  end

  def pipes_pos
    active_pipes.map do |pipe|
      pipe.pos
    end
  end

  def pipes_next_pos
    active_pipes.map do |pipe|
      pipe.next_pos
    end
  end

  def collision?(x, y)
    pipes_next_pos.any? do |pos|
      a = pos[:x] == x && (y <= pos[:top] || pos[:bottom] <= y)
      a
    end
  end

  def create_background(w)
    Array.new(w) { sample_bg }
  end

  def sample_bg
    [*0..(@bg_kinds-1)].sample
  end

  def background
    @background
  end

  def update_background
    @background.shift
    @background.push(sample_bg)
  end

  def count_pipes_more_left(x)
    @pipes.select { |p| p.x <= x }.size
  end

  def create_pipe
    pipe = Pipe.new(@width, @height)
    @pipes.push(pipe)
  end

  def active_pipes
    @pipes.select { |p| p.x > 0 }
  end

  def update
    active_pipes.each { |p| p.update }

    @countup_create_pipe += 1
    if @countup_create_pipe > @@create_pipe_wait_frame
      create_pipe
      @countup_create_pipe = 0
    end

    update_background
  end
end
