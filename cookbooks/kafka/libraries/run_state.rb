module KafkaRunStateHelpers
  def kafka_brokers(cluster = node.cluster_name)
    node.run_state[:nodes].select do |n|
      n.role?("kafka") and
      n.cluster_name == cluster
    end
  end

  def kafka_connect(cluster = node.cluster_name)
    kafka_brokers(cluster).map do |broker|
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
