require './pipe.rb'

class Map
  @@create_pipe_wait_frame = 5

  def initialize(width, height)
    @pipes = []
    @width = width
    @height = height
    @countup_create_pipe = 0
  end

  def pipes
    @pipes
  end

  def create_pipe
    pipe = Pipe.new(@width, @height)
    @pipes.push(pipe)
  end

  def update
    @pipes.each { |p| p.update }
    @pipes = @pipes.select { |p| p.x > 0 }

    @countup_create_pipe += 1
    if @countup_create_pipe > @@create_pipe_wait_frame
      create_pipe
      @countup_create_pipe = 0
    end
  end
end
