#!/usr/bin/env ruby

require 'nagios'

class KafkaPartioning < Nagios::Plugin
  def initialize
    super

    @kafka_bindir = "~kafka/current/bin"

    @config.options.on('-Z', '--zookeeper=URI',
      'Zookeeper URL') { |zk_uri| @zk_uri = zk_uri }
    @config.options.on('-k', '--kafka-bindir=PATH',
      'kafka-runner.sh to use') { |kafka_bindir| @kafka_bindir = kafka_bindir }
    @config.options.on('-t', '--topics=TOPIC,TOPIC,...',
      'which topics to check') { |topics| @topics = topics.split(',') }
    @config.options.on('-n', '--kafka-id=id',
      'which kafka-id to check (defaults to all)') { |kafka_id| @kafka_id = kafka_id.to_i}

    @config.parse!
    raise "No zookeeper given" unless @zk_uri
    raise "No topics given" unless @topics
    raise "No kafka-id given" unless @kafka_id
  end

  def warning(m)
    !m.all? do |info|
      info[:isr].include? @kafka_id
    end
  end

  def critical(m)
   m.select{|info| info[:replicas][0] == @kafka_id}.any? do |info|
      info[:leader] != @kafka_id
    end
  end

  def to_s(m)
    msg = "Kafka #{@kafka_id}"
    if (critical(m))
      msg = "\nshould be leader on\n"
      msg += m.select{|info| info[:replicas][0] == @kafka_id && info[:leader] != @kafka_id}.join(",\n")
    end
    if (warning(m))
      msg += "\nshould be isr on\n"
      msg += m.select{|info| info[:replicas].include?(@kafka_id) && !info[:isr].include?(@kafka_id) }.join(",\n")
    end
    msg
  end

  def measure
    result = []

    @topics.each do |topic|
      raw = %x{#{@kafka_bindir}/kafka-list-topic.sh --zookeeper #{@zk_uri} --topic #{topic}}
      raw.split("\n").each do |row|
        raw = row.match(/topic: (.*)\tpartition: (\d+)\tleader: (\d+)\treplicas: (.*)\tisr: (.*)/)
        info = {
          topic: raw[1],
          partition: raw[2],
          leader: raw[3].to_i,
          replicas: raw[4].split(',').map(&:to_i),
          isr: raw[5].split(',').map(&:to_i),
        }
        result << info if info[:replicas].include?(@kafka_id)
      end
    end

    result
  end
end

KafkaPartioning.run!
