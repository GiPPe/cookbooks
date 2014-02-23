module ZookeeperRunStateHelpers
  def zookeeper_nodes(ensemble = node.cluster_name)
    node.run_state[:nodes].select do |n|
      n.role?("zookeeper") and
      n.cluster_name == ensemble
    end
  end

  def zookeeper_connect(zk_root, ensemble = node.cluster_name)
    url = zookeeper_nodes(ensemble).map do |n|
      "#{n[:ipaddress]}:2181"
    end.join(',')

    if zk_root
      zk_root = zk_root.to_s.strip
      url += "/" unless zk_root[0] == "/"
      url += zk_root
    end

    url
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
