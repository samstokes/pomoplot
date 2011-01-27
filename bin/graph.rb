require 'date'
require 'redis'
require 'gerbilcharts'

require File.join(File.dirname(__FILE__), *%w(.. lib backend))
require File.join(File.dirname(__FILE__), *%w(.. lib config))
require File.join(File.dirname(__FILE__), *%w(.. lib day))

include Pomoplot

config = Pomoplot::Config.user

redis = Redis.connect(:url => config['redis'])
backend = Backend.new(redis, config['bucket'])

days = backend.days(Date.today - 28)

GerbilCharts::Charts::LineChart.new(
  :width => 600,
  :height => 300,
  :style => 'brushmetal.css',
  :javascripts => 'gerbil.js',
  :scaling_y => :auto_0,
  :circle_data_points => true,
  :auto_tooltips => true,
  :enabletimetracker => true
).tap do |chart|
  GerbilCharts::Models::SimpleTimeSeriesModelGroup.new(
    :title => "#{config['user']} Pomodoros",
    :timeseries => days.map(&:date).map(&:to_time),
    :models => [['Pomos', *days.map(&:pomos)]]
  ).tap do |modelgroup|
    chart.modelgroup = modelgroup
    chart.render_string.tap do |svg|
      puts svg
    end
  end
end
