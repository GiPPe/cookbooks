#!/usr/bin/env ruby

require 'nagios'
require 'time'
require 'open-uri'
require 'yajl'
require 'set'
require 'resolv'

module Usage
  def usage(m)
    Hash[m.map { |node| [node[:host], node[:currSize].to_f / node[:maxSize].to_f * 100] }]
  end

  def warning(m)
    usage(m).values.any? do |value|
      value > threshold(:warning)
    end
  end

  def critical(m)
    usage(m).values.any? do |value|
      value > threshold(:critical)
    end
  end

  def to_s(m)
    usage(m).select do |ip, value|
      value > threshold(:warning)
    end.map do |ip, value|
      address = ip.split(':').first
      name = Resolv.getname(address) rescue address
      "#{name}: #{value.round}%"
    end.sort.join(', ')
  end
end

module Intervals
  def segments(m)
    m.map { |node| node[:segments].values }.flatten
  end

  def intervals(m)
    {}.tap do |intervals|
      segments(m).each do |segment|
        next if (@db && segment[:dataSource] != @db)
        intervals[segment[:dataSource]] ||= SortedSet.new
        intervals[segment[:dataSource]] << segment[:interval]
      end
    end
  end

  def gaps(m)
    gaps = {}

    intervals(m).map do |source, intervals|
      min = nil

      ranges = intervals.map do |interval|
        start, stop = interval.split('/').map{|timestamp| DateTime.parse(timestamp).to_time.to_i }
        min ||= start
        min = [start, min].min
        (start ... stop)
      end

      min = [min, (Date.today - 60).to_time.to_i].min

      min.step(Time.now.to_i, 3600).each do |hour|
        if ranges.any? {|range| range.include?(hour)}
          # we found a segment, hurray
        elsif @whitelist.include?(hour)
          # we found a whitelisted segment, I haz a sad
        else
          # houston
          gap = gaps[source] ||= SortedSet.new
          gap << Time.at(hour).utc
        end
      end
    end

    gaps
  end

  def critical(m)
    gaps(m).any?
  end

  def to_s(m)
    if gaps(m).any?
      "missing intervals: #{gaps(m).inspect}"
    else
      "no missing intervals"
    end
  end
end

Class.new(Nagios::Plugin) do
  def initialize
    super

    @nodes = []
    @homedir = "/var/app/druid"
    @db = nil
    @whitelist = Set.new

    @config.options.on('-m', '--mode=MODE',
      'Mode to use (pubsub, ad_provider_times, ...)') { |mode| @mode = mode }
    @config.options.on('-u', '--url=URL',
      'Which URL to query for stats') { |url| @url = url}
    @config.options.on('-n', '--nodes=NODE,NODE,...',
      'Which URL to query for stats') { |node| @nodes << node }
    @config.options.on('-D', '--homedir=DIR',
      'Kafka Home Directory') { |homedir| @homedir = homedir }
    @config.options.on('-d', '--db=DATABASE',
      'Druid DB to Check') { |db| @db = db}
    @config.options.on('-W', '--whitelist=TS,TS,TS,...',
      'Which Segments to whitelist in check') {|whitelist| whitelist.split(',').each {|w| @whitelist << Time.parse(w).to_i } }

    @config.parse!
    raise "No mode given" unless @mode

    self.extend(Object.const_get(@mode.to_sym))
  end

  def warning(m)
    false
  end

  def parse(json)
    Yajl::Parser.new(:symbolize_keys => true).parse(json)
  end

  def measure
    @stats ||= parse(open(@url))
  end
end.run!
