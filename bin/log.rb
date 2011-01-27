require 'date'
require 'redis'

require File.join(File.dirname(__FILE__), *%w(.. lib backend))
require File.join(File.dirname(__FILE__), *%w(.. lib config))
require File.join(File.dirname(__FILE__), *%w(.. lib day))

include Pomoplot

config = Pomoplot::Config.user

redis = Redis.connect(:url => config['redis'])
backend = Backend.new(redis, config['bucket'])

puts "Hi, #{config['user']}!"
backend.last_day.tap do |last|
  if last
    puts "You last logged #{last.pomos} pomos on #{last.date}."
  else
    puts "You've never logged any pomos!"
  end
  puts
end

response = nil
days = []
while response !~ /^q/i
  print "Log pomos? ('quit' to quit) "
  response = readline
  words = response.split
  pomos = words.grep(/^\d+$/).map(&:to_i).first
  date = words.map do |word|
    if word =~ /^\d+$/
      nil
    else
      Date.parse(word) rescue nil
    end
  end.compact.first
  next unless pomos
  date ||= Date.today
  day = Day[date]
  day.pomos = pomos
  days << day
  puts "OK, #{pomos} pomos on #{date}."
end

backend.update_days(days)

puts "Logged #{days.size} days."
