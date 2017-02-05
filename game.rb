class Game

  @@e = {
    :bird => ':flappybird:',
    :blank => ':block_bl:',
    :pipe_down => ':pipe_down:',
    :pipe_up => ':pipe_up:',
    :pipe_end_down => ':pipe_end_down:',
    :pipe_end_up => ':pipe_end_up:',
  }

  def initialize(channel)
    start(channel)
    main_loop
  end

  def start(channel)
    @text = 'slappy bird!'
    params =
    {
      channel: channel,
      text: @text,
    }
    #binding.pry
    @post = Slack.chat_postMessage(params)
    @tap = 0

    reaction(@post)
  end

  def reaction(post)
    params =
    {
      name: "point_up_2",
      channel: post['channel'],
      timestamp: post['ts'],
    }
    puts Slack.reactions_add(params)
  end

  def main_loop
    thread = Thread.start {
      every_seconds(1) do
        if @gameover
          thread.join
          break
        end

        update
      end
    }
  end

  def every_seconds(n)
    loop do
      before = Time.now
      yield
      sleep(n)
    end
  end

  def update
    return if @post.nil?
    update_text
    chat_update
  end

  def update_text
    if @tap > 0
      @text += '?'
      @tap = 0
    else
      @text += '!'
    end
  end

  def chat_update
    params =
    {
      ts: @post['ts'],
      channel: @post['channel'],
      text: @text,
    }
    Slack.chat_update(params)
  end

  def ts
    @post['ts']
  end

  def tap
    @tap += 1
  end
end
