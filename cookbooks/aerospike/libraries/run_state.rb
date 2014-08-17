module AerospikeHelpers
  def aerospike_nodes(cluster_name = node.cluster_name)
    node.nodes.cluster(cluster_name).role("aerospike")
  end
end

include AerospikeHelpers

class Aerospike
  class Recipe
    include AerospikeHelpers
  end

  class Node
    include AerospikeHelpers
  end

  class Resource
    include AerospikeHelpers
  end
end
