module Pomoplot
  class Day
    attr_accessor :pomos
    attr_reader :date

    def initialize(date)
      @date = date
      @pomos = 0
    end

    def iso8601
      @date.iso8601
    end

    def timestamp
      @date.to_time.tv_sec
    end

    class << self
      def [](date)
        @days ||= Hash.new {|hash, date| hash[date] = new(date) }
        @days[date]
      end

      def all
        @days.values
      end
    end
  end
end
