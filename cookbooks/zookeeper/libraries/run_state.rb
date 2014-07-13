module ZookeeperRunStateHelpers
  def zookeeper_nodes(cluster_name = node.cluster_name)
    node.nodes.cluster(cluster_name).role("zookeeper")
  end

  def zookeeper_connect(zk_root, cluster_name = node.cluster_name)
    url = zookeeper_nodes(cluster_name).map do |n|
      "#{n[:ipaddress]}:2181"
    end.join(',')
    zk_root = zk_root.to_s.strip
    url += "/" unless zk_root[0] == "/"
    url += zk_root
  end
end

include ZookeeperRunStateHelpers

class Chef
  class Recipe
    include ZookeeperRunStateHelpers
  end

  class Node
    include ZookeeperRunStateHelpers
  end

  class Resource
    include ZookeeperRunStateHelpers
  end
end
