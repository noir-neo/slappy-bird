class Game
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
    if @tap > 0
      @text += '?'
      @tap = 0
    else
      @text += '!'
    end
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
