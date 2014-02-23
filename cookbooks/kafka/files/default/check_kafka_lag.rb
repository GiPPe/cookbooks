#!/usr/bin/env ruby

require 'nagios'
require 'yaml'
require 'thread'

class KafkaLagCheck < Nagios::Plugin
  def initialize
    super

    # defaults
    @zk_cli = "/opt/zookeeper/bin/zkCli.sh"
    @kafka_runner = "~kafka/current/bin/kafka-run-class.sh"

    @warn_level = 1073741824
    @critical_level = 3221225472
    @groups = nil

    @config.options.on('-Z', '--zookeeper=URI',
      'Zookeeper URL') { |zk_uri| @zk_uri = zk_uri }
    @config.options.on('-c', '--zkCli=CMD',
      'zkCli.sh to use') { |zk_cli| @zk_cli = zk_cli }
    @config.options.on('-k', '--kafka-runner=CMD',
      'kafka-runner.sh to use') { |kafka_runner| @kafka_runner = kafka_runner }
    @config.options.on('-w', '--warning-lag=BYTES',
      'when to warn (in bytes)') { |warn_level| @warn_level = warn_level.to_i }
    @config.options.on('-e', '--error-lag=BYTES',
      'when be critical (in bytes)') { |critical_level| @critical_level = critical_level.to_i }
    @config.options.on('-g', '--groups=GROUP,GROUP,...',
      'which groups to check (defaults to all)') { |groups| @groups = groups.split(',') }

    @config.parse!
    raise "No zookeeper given" unless @zk_uri
  end

  def zk_list(path)
    raw = %x{#{@zk_cli} -server #{@zk_uri} ls #{path}}
    YAML::load(raw[raw.index('[') ... -1])
  end

  def warning(m)
    m[:lagging].any? {|check| check[:lag] > @warn_level }
  end

  def critical(m)
    m[:unowned].size > 0 ||
    m[:lagging].any? {|check| check[:lag] > @critical_level }
  end

  def to_s(m)
    literal = ""

    reports = m[:lagging]
    critical = reports.select{ |check| check[:lag] >= @critical_level}
    warning =  reports.select{ |check| check[:lag] > @warn_level} - critical
    ok = reports - warning - critical

    literal += "Kafka groups with out an active client\n#{ m[:unowned].to_yaml }" if m[:unowned].size > 0
    literal += "Lag > #{@critical_level} bytes\n#{ critical.to_yaml }" if critical.size > 0
    literal += "Lag > #{@warn_level} bytes\n#{ warning.to_yaml }" if warning.size > 0
    literal += "Lag with OK lag\n#{ok.to_yaml}" if ok.size > 0

    literal += "\n"
    literal
  end

  def measure
    @groups ||= zk_list('/consumers').reject do |raw|
      group = raw.to_s
      group.start_with?('console-consumer') || group.include?('test')
    end

    result = {
      lagging: [],
      unowned: []
    }

    # poor mans thread pool so we are gem free
    run_locks = [Mutex.new, Mutex.new, Mutex.new, Mutex.new]
    write_lock = Mutex.new

    @groups.each do |group|
      Thread.new do
        run_locks.sample.synchronize do
          lag_check = %x{#{@kafka_runner} kafka.tools.ConsumerOffsetChecker --zkconnect #{@zk_uri} --group #{group} 2>/dev/null}
          puts "\nWARNING: failed to query #{group}" unless $? == 0

          lag_info = lag_check.split("\n")[1 .. -1].map do |line|
            info = line.split;
            {
              owner: info[-1],
              lag: info[-2].to_i
            }
          end

          if lag_info.size == 0
            result[:unowned] << group
          else
            lag = lag_info.inject(0) { |sum, row| sum + row[:lag]}
            result[:lagging] << {group: group, lag: lag} if lag > 0
          end
        end
      end
    end

    # wait for "thread group"
    while ThreadGroup::Default.list.size > 1
      sleep 1
    end

    result
  end
end

KafkaLagCheck.run!
