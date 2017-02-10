require 'slack'
require './game.rb'
require 'pry'

token = ENV['SLACK_TOKEN'] || (print "Token: "; gets.strip)

Slack.configure {|config| config.token = token }
client = Slack.realtime

games = []

client.on :hello do
  puts 'Connected.'
end

client.on :message do |data|
  if data['text'] == 'slappybird' && data['subtype'] != 'bot_message'
    games.push(Game.new(data['channel']))
  end
end

client.on :reaction_added do |data|
  puts data
  #return if data[]
  games.each do |game|
    if data['item']['ts'] == game.ts
      game.tap
    end
  end
end

client.on :reaction_removed do |data|
  puts data['item']
  games.each do |game|
    if data['item']['ts'] == game.ts
      game.tap
    end
  end
end

client.start
