module Hadoop2RunStateHelpers
  def hadoop2_historyservers(cluster_name = node[:hadoop2][:cluster])
    node.nodes.cluster(cluster_name).role("hadoop2-historyserver")
  end

  def hadoop2_historyserver(cluster_name = node[:hadoop2][:cluster])
    hadoop2_historyservers(cluster_name).first
  end

  def hadoop2_journalnodes(cluster_name = node[:hadoop2][:cluster])
    node.nodes.cluster(cluster_name).role("hadoop2-journalnode")
  end

  def hadoop2_namenodes(cluster_name = node[:hadoop2][:cluster])
    node.nodes.cluster(cluster_name).role("hadoop2-namenode")
  end

  def hadoop2_resourcemanagers(cluster_name = node[:hadoop2][:cluster])
    node.nodes.cluster(cluster_name).role("hadoop2-resourcemanager")
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
