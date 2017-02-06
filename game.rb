require './bird.rb'
require 'pry'

class Game

  @@width = 11
  @@height = 12

  @@f = {
    0 => ':flappybird:',
    -30 => ':flappybird-30:',
    -60 => ':flappybird-60:',
    -90 => ':flappybird-90:',
    30 => ':flappybird--30:',
    60 => ':flappybird--60:',
    90 => ':flappybird--90:',
  }

  @@m = {
    :bl => ':block_bl:',
    :pd => ':pipe_down:',
    :pu => ':pipe_up:',
    :ed => ':pipe_end_down:',
    :eu => ':pipe_end_up:',
    :gr => ':cactus:',
  }

  @@num = [
    ':one:',
    ':two:',
    ':three:',
    ':four:',
    ':five:',
    ':six:',
    ':seven:',
    ':eight:',
    ':nine:'
  ]

  def initialize(channel)
    start(channel)
    main_loop
  end

  def start(channel)
    @bird = Bird.new(@@height)

    params =
    {
      channel: channel,
      text: title_text,
    }
    #binding.pry
    @post = Slack.chat_postMessage(params)

    reaction(@post)
  end

  def reaction(post)
    params =
    {
      name: 'point_up_2',
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
          puts 'gameover'
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

    @bird.update

    chat_update
  end

  def chat_update
    params =
    {
      ts: @post['ts'],
      channel: @post['channel'],
      text: update_text,
    }
    Slack.chat_update(params)
  end

  def array_to_text(arr)
    arr.map { |t| t.join } .join("\n")
  end

  def render_clear
    Array.new(@@height) { Array.new(@@width) { @@m[:bl] } }
  end

  def render_bird(arr)
    arr[@@height - @bird.altitude][3] = @@f[@bird.angle]
    arr
  end

  def render_map(arr)
    arr[@@height - 1] = arr[@@height - 1].map { |e| e = @@m[:gr] }
    arr
  end

  def title_text
    arr = render_clear
    arr = render_map(arr)
    arr = render_bird(arr)
    array_to_text(arr)
  end

  def update_text
    arr = render_clear
    arr = render_map(arr)
    arr = render_bird(arr)
    array_to_text(arr)
  end



  def ts
    @post['ts']
  end

  def tap
    @bird.tap
  end
end
