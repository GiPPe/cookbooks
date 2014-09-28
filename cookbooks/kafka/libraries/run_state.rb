module KafkaRunStateHelpers
  def kafka_brokers(cluster_name = node.cluster_name)
    node.nodes.cluster(cluster_name).role("kafka")
  end

  def kafka_connect(cluster_name = node.cluster_name)
    kafka_brokers(cluster_name).map do |broker|
      "#{broker[:ipaddress]}:9092"
    end.join(',')
  end
end

include KafkaRunStateHelpers

class Chef
  class Recipe
    include KafkaRunStateHelpers
  end

  class Node
    include KafkaRunStateHelpers
  end

  class Resource
    include KafkaRunStateHelpers
  end
end
