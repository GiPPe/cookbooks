module Splunk6RunStateHelpers
  def splunk6_nodes
    node.run_state[:nodes].select do |n|
      n.role?("splunk6")
    end
  end

  def splunk6_master_node?(n = nil)
    n ||= node
    n.role?("splunk6-master")
  end

  def splunk6_master_node
    splunk6_nodes.select do |n|
      splunk6_master_node?(n)
    end.first
  end

  def splunk6_peer_node?(n = nil)
    n ||= node
    n.role?("splunk6-peer")
  end

  def splunk6_peer_nodes
    splunk6_nodes.select do |n|
      splunk6_peer_node?(n)
    end
  end

  def splunk6_search_head?(n = nil)
    n ||= node
    n.role?("splunk6-search")
  end

  def splunk6_search_heads
    splunk6_nodes.select do |n|
      splunk6_search_head?(n)
    end
  end

  def splunk6_search_node?(n = nil)
    n ||= node
    splunk6_search_head?(n) or
    n.role?("splunk6-server")
  end

  def splunk6_search_nodes
    splunk6_nodes.select do |n|
      splunk6_search_node?(n)
    end
  end

  def splunk6_forwarder?
    gentoo? &&
    splunk6_nodes.any? && [
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

include Splunk6RunStateHelpers

class Chef
  class Recipe
    include Splunk6RunStateHelpers
  end

  class Node
    include Splunk6RunStateHelpers
  end

  class Resource
    include Splunk6RunStateHelpers
  end
end
