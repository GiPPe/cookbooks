require 'optparse'

module Nagios

  EXIT_OK = 0
  EXIT_WARNING = 1
  EXIT_CRITICAL = 2
  EXIT_UNKNOWN = 3

  class Plugin

    class << self
      def run!
        new.run!
      end
    end

    def initialize
      @config = Nagios::Config.new
      @status_used = nil
    end

    def run!
      @config.parse!
      begin
        @value = measure
        if critical(@value)
          exit_with :critical, get_msg(:critical, @value)
        elsif warning(@value)
          exit_with :warning, get_msg(:warning, @value)
        else
          exit_with :ok, get_msg(:ok, @value)
        end
      rescue => e
        exit_exception e
      end
    end

    def threshold(level)
      if level == :warning
        @config[:warning] || -1
      elsif level == :critical
        @config[:critical] || -1
      else
        -1
      end
    end

    def to_s(value)
      "#{value}"
    end

    def status
      @status_used = true
      @status
    end

    private

    def get_msg(level, value)
      msg_method = "#{level}_msg".to_sym
      if self.respond_to?(msg_method)
        self.send(msg_method, value)
      else
        value
      end
    end

    def exit_with(level, value)
      @status = level.to_s.upcase
      msg = to_s(value)
      if @status_used
        puts msg
      else
        puts "#{@status}: #{msg}"
      end
      exit Nagios.const_get("EXIT_#{@status}")
    end

    def exit_exception(exc)
      puts "Exception: #{exc} (#{exc.backtrace})"
      exit Nagios::EXIT_CRITICAL
    end

  end

  class Config

    attr_accessor :options

    def initialize
      @settings = {}
      @options = OptionParser.new do |options|
        options.on("-wWARNING",
                   "--warning=WARNING",
                   "Warning Threshold") do |x|
          @settings[:warning] = int_if_possible(x)
        end
        options.on("-cCRITICAL",
                   "--critical=CRITICAL",
                   "Critical Threshold") do |x|
          @settings[:critical] = int_if_possible(x)
        end
      end
    end

    def [](setting)
      @settings[setting]
    end

    def []=(field, value)
      @settings[field] = value
    end

    def parse!
      @options.parse!
    end

    private
      def int_if_possible(x)
        (x.to_i > 0 || x == '0') ? x.to_i : x
      end
  end
end
