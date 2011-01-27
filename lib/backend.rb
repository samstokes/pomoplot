require File.join(File.dirname(__FILE__), 'day')
require File.join(File.dirname(__FILE__), 'enumerable')

module Pomoplot
  class Backend
    def initialize(redis, bucket)
      @redis = redis
      @bucket = "Pomoplot:#{bucket}"
    end

    def update_days(days)
      @redis.multi do
        days.each {|day| update_day(day) }
      end
    end

    def update_all
      update_days(Day.all)
    end

    def update_day(day)
      @redis.zadd @bucket, day.timestamp, day_to_label(day)
    end

    def days(from_date = nil, to_date = nil)
      from_stamp = from_date.to_time.tv_sec rescue '-inf'
      to_stamp = to_date.to_time.tv_sec rescue '+inf'
      @redis.zrangebyscore(@bucket, from_stamp, to_stamp, :with_scores => true).
        paired.map {|value, score| load_day(value, score.to_i) }
    end

    def last_day
      value, score = @redis.zrevrange @bucket, 0, 0, :with_scores => true
      return nil unless value
      load_day(value, score.to_i)
    end

    private
    def day_to_label(day)
      "#{day.iso8601}:#{day.pomos}"
    end

    def label_to_day(label)
      date, pomos, junk = label.split(':', 3)
      raise ArgumentError, "junk '#{junk}' at end of label '#{label}'" if junk
      raise ArgumentError, "bad label format '#{label}'" unless pomos && pomos =~ /^\d+$/

      Day[Date.parse(date)].tap {|day| day.pomos = pomos.to_i }
    end

    def load_day(value, score)
      label_to_day(value).tap do |day|
        unless day.timestamp == score
          raise "timestamp #{score} and label date #{value} do not match!"
        end
      end
    end
  end
end
