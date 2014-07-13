module DruidHelpers
  def druid_version
    @druid_version ||= mvn_project_version("/var/app/druid/current")
  end

  def druid_realtime_spec
    node[:druid][:sources].map do |source, config|
      {
        schema: {
          dataSource: source,
          aggregators: config[:aggregators].map do |name, aggregator|
            { type: aggregator, name: name, fieldName: name }
          end + [{ type: "count", name: "events" }],
          indexGranularity: config[:granularity],
          shardSpec: {
            type: "linear",
            partitionNum: node[:cluster][:host][:id],
          },
        },
        config: {
          maxRowsInMemory: 1000000,
          intermediatePersistPeriod: "PT10m",
        },
        firehose: {
          type: "kafka-0.8",
          consumerProps: {
            "group.id" => "#{node[:cluster][:host][:group]}.#{node.cluster_name}-#{source}",
            "zookeeper.connect" => zookeeper_connect(node[:kafka][:zookeeper][:root], node[:kafka][:zookeeper][:cluster]),
            "zookeeper.session.timeout.ms" => "15000",
            "zookeeper.sync.time.ms" => "5000",
            "rebalance.max.retries" => "64",
            "auto.commit.enable" => "false",
            "fetch.message.max.bytes" => "1048576",
          },
          feed: source,
          parser: {
            timestampSpec: {
              column: config[:timestamp][:column],
              format: config[:timestamp][:format],
            },
            data: {
              format: "json",
              dimensions: config[:dimensions],
            },
          },
        },
        plumber: {
          type: "realtime",
          windowPeriod: "PT10m",
          rejectionPolicy: { type: "serverTime" },
          segmentGranularity: "hour",
          basePersistDirectory: "/var/app/druid/storage/realtime/#{source}",
        },
      }
    end
  end
end

include DruidHelpers

class Chef
  class Recipe
    include DruidHelpers
  end

  class Node
    include DruidHelpers
  end

  class Resource
    include DruidHelpers
  end
end
