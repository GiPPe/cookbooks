#!/usr/bin/env ruby

require 'nagios'
require 'time'
require 'open-uri'
require 'yajl'

module NameNode
  def bean
    "Hadoop:service=NameNode,name=NameNodeInfo"
  end

  def critical(m)
    parse(m[:DeadNodes]).any? or
    parse(m[:DecomNodes]).any? or
    parse(m[:NameDirStatuses])[:failed].any?
  end

  def to_s(m)
    "DeadNodes: #{m[:DeadNodes]}, DecomNodes: #{m[:DecomNodes]}, NameDirStatuses: #{m[:NameDirStatuses]}"
  end
end

module Dfs
  def bean
    "Hadoop:service=NameNode,name=FSNamesystemState"
  end

  def critical(m)
    m[:FSState] != "Operational"
  end

  def to_s(m)
    "HDFS is #{m[:FSState]}"
  end
end

module DfsCapacity
  def bean
    "Hadoop:service=NameNode,name=NameNodeInfo"
  end

  def warning(m)
    m[:PercentUsed] > threshold(:warning).to_f
  end

  def critical(m)
    m[:PercentUsed] > threshold(:critical).to_f
  end

  def to_s(m)
    "PercentUsed: #{m[:PercentUsed]}%"
  end
end

module DfsBlocks
  def measure
    out = %x(/opt/hadoop/bin/hadoop dfsadmin -report | head -n8 | tail -n-3 | awk -F: '{print $2}')
    out.split.map(&:to_i)
  end

  def warning(m)
    [m[0] > 100, m[1] > 0].any?
  end

  def critical(m)
    m[2] > 0
  end

  def to_s(m)
    "MissingBlocks: #{m[2]}, CorruptBlocks: #{m[1]}, UnderReplicatedBlocks: #{m[0]}"
  end
end

module DataNode
  def bean
    "Hadoop:service=DataNode,name=FSDatasetState-*"
  end

  def percent_used(m)
    (m[:DfsUsed].to_f / m[:Capacity].to_f * 100).round
  end

  def warning(m)
    percent_used(m) > threshold(:warning).to_f
  end

  def critical(m)
    percent_used(m) > threshold(:critical).to_f
  end

  def to_s(m)
    "PercentUsed: #{percent_used(m)}%"
  end
end

Class.new(Nagios::Plugin) do
  def initialize
    super

    @config.options.on('-m', '--mode=MODE',
      'Mode to use (pubsub, ad_provider_times, ...)') { |mode| @mode = mode }
    @config.options.on('-u', '--url=URL',
      'Which URL to query for stats') { |url| @url = url}

    @config.parse!
    raise "No mode given" unless @mode
    raise "No URL given" unless @url

    self.extend(Object.const_get(@mode.to_sym))
  end

  def warning(m)
    false
  end

  def parse(json)
    Yajl::Parser.new(:symbolize_keys => true).parse(json)
  end

  def measure
    @stats ||= parse(open(@url))[:beans].select do |obj|
      obj[:name] =~ Regexp.new(bean)
    end.first
  end
end.run!
