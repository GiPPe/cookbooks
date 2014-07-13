module Hadoop2RunStateHelpers
  def hadoop2_clusters
    result = Hash.new do |hash,key|
      hash[key] = {
        nn: [],
        jn: [],
        dn: [],
        rm: [],
        nm: [],
        hs: [],
      }
    end

    node.nodes.each do |n|
      if n[:hadoop2] && n[:hadoop2][:cluster]
        result[n[:hadoop2][:cluster]][:nn] << n if n.role?("hadoop2-namenode")
        result[n[:hadoop2][:cluster]][:jn] << n if n.role?("hadoop2-journalnode")
        result[n[:hadoop2][:cluster]][:dn] << n if n.role?("hadoop2-datanode")
        result[n[:hadoop2][:cluster]][:rm] << n if n.role?("hadoop2-resourcemanager")
        result[n[:hadoop2][:cluster]][:nm] << n if n.role?("hadoop2-nodemanager")
        result[n[:hadoop2][:cluster]][:hs] << n if n.role?("hadoop2-historyserver")
      end
    end

    result
  end

  def hadoop2_datanodes
    node.nodes.role("hadoop2-datanode")
  end

  def hadoop2_topology
    Hash[node.nodes.map do |n|
      rack_id_v2 = n[:hadoop2] && n[:hadoop2][:rack_id]

      rack_id = rack_id_v2 || "/default-rack/#{node.cluster_name}"

      [n, rack_id]
    end]
  end
end

include Hadoop2RunStateHelpers

class Chef
  class Recipe
    include Hadoop2RunStateHelpers
  end

  class Node
    include Hadoop2RunStateHelpers
  end

  class Resource
    include Hadoop2RunStateHelpers
  end
end
