module SplunkRunStateHelpers
  def splunk_nodes
    node.run_state[:nodes].select do |n|
      n.role?("splunk-master") or
      n.role?("splunk-peer") or
      n.role?("splunk-search") or
      n.role?("splunk-server")
    end
  end

  def splunk_master_node
    node.run_state[:nodes].select do |n|
      n.role?("splunk-master")
    end.first
  end

  def splunk_peer_nodes
    node.run_state[:nodes].select do |n|
      n.role?("splunk-peer") or
      n.role?("splunk-server")
    end
  end

  def splunk_search_nodes
    node.run_state[:nodes].select do |n|
      n.role?("splunk-search") or
      n.role?("splunk-server")
    end
  end

  def splunk_forwarder?
    gentoo? &&
    splunk_nodes.any? && [
      node.role?("splunk-master"),
      node.role?("splunk-peer"),
      node.role?("splunk-search"),
      node.role?("splunk-server"),
      node.role?("splunk6-master"),
      node.role?("splunk6-peer"),
      node.role?("splunk6-search"),
      node.role?("splunk6-server"),
    ].none?
  end
end

include SplunkRunStateHelpers

class Chef
  class Recipe
    include SplunkRunStateHelpers
  end

  class Node
    include SplunkRunStateHelpers
  end

  class Resource
    include SplunkRunStateHelpers
  end
end
