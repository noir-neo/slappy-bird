require './bird.rb'
require './map.rb'
require 'pry'

class Game

  @@width = 12
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
    :pi => ':pipe:',
    :ed => ':pipe_end_down:',
    :eu => ':pipe_end_up:',
  }

  @@bg = [
    ':cactus:',
    ':house_with_garden:',
    ':deciduous_tree:',
    ':evergreen_tree:',
  ]

  @@num = [
    ':zero:',
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
  end

  def start(channel = nil)
    @startgame = nil
    @bird = Bird.new(@@height)
    @map = Map.new(@@width, @@height, @@bg.size)

    unless @post || channel.nil?
      @post = post_message(channel, title_text)
      reaction(@post)
    else
      @startgame = false
      chat_update(title_text)
    end

    main_loop
  end

  def post_message(channel, text)
    params =
    {
      channel: channel,
      text: text,
      icon_emoji: @@f[0],
      username: 'Slappy Bird'
    }
    Slack.chat_postMessage(params)
  end

  def reaction(post)
    params =
    {
      name: 'point_up_2',
      channel: post['channel'],
      timestamp: post['ts'],
    }
    Slack.reactions_add(params)
  end

  def main_loop
    thread = Thread.start {
      every_seconds(1) do
        if @startgame
          if gameover?
            thread.join
            break
          end

          update
        end
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

    if @bird.live?
      if @map.collision?(@bird.x, @bird.y)
        @bird.kill
      else
        @map.update
      end
    end

    chat_update(update_text)
  end

  def chat_update(text)
    params =
    {
      ts: @post['ts'],
      channel: @post['channel'],
      text: text,
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
    arr[@bird.y][@bird.x] = @@f[@bird.angle]
    arr
  end

  def render_map(arr)
    @map.background.each_with_index do |bg, i|
      arr[@@height - 1][i] = @@bg[bg]
    end


    @map.pipes_pos.each do |pos|
      [*0..pos[:top]].each do |down|
        arr[down][pos[:x]] = @@m[:pi]
      end
      [*pos[:bottom]..@@height-1].each do |up|
        arr[up][pos[:x]] = @@m[:pi]
      end
      arr[pos[:top]][pos[:x]] = @@m[:ed]
      arr[pos[:bottom]][pos[:x]] = @@m[:eu]
    end
    arr
  end

  def render_ui(arr)
    digits = get_digits(score)
    count = digits.size
    digits.each_with_index do |item, idx|
      arr[0][@@width/2 - count/2 + idx] = @@num[item]
    end
    arr
  end

  def get_digits(n)
    n.abs.to_s.each_byte.map{|b| b - 0x30}
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
    arr = render_ui(arr)
    array_to_text(arr)
  end

  def gameover?
    @bird.ground?
  end

  def score
    @map.count_pipes_more_left(@bird.x)
  end

  def ts
    @post['ts']
  end

  def tap
    if @startgame.nil?
      @startgame = false
      return
    end

    if gameover?
      start
      return
    end

    @bird.tap
    @startgame = true
  end
end
