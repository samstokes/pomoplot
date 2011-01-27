require 'yaml'

module Pomoplot
  module Config
    class << self
      def load(path)
        open(path) {|yaml| YAML.load(yaml) }
      end

      def user
        load(File.join(ENV['HOME'], '.pomoplot.yml'))
      end
    end
  end
end
