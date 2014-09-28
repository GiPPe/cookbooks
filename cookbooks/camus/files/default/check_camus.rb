#!/usr/bin/env ruby

require 'nagios'
require 'time'

class CheckCamus < Nagios::Plugin
  def initialize
    super
    @hadoop = "/var/app/hadoop2/current/bin/hdfs"

    @config.options.on('-p', '--path=PATH',
      'Path to check') { |path| @path = path }

    @config.options.on('-x', '--hadoop=EXECUTABLE',
      'Full name of hadoop executable') { |hadoop| @hadoop = hadoop }

    @config.parse!
    raise "No path given" unless @path
  end

  def measure
    raw = %x{#{@hadoop} dfs -ls -R #{@path} 2>/dev/null|tail -1}
    parts = raw.split(' ')[-1].split('/') rescue [0,0,0,0,2000,1,1,0]
    (Time.now - Time.parse("#{parts[4..6].join('-')}T#{parts[7]}:00Z")) / 60 / 60 # hours
  end

  def warning(m)
    m > 2
  end

  def critical(m)
    m > 3
  end

  def to_s(m)
    "Camus lag is #{m.round(1)}h"
  end

end

CheckCamus.new.run!
