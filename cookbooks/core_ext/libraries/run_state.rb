module RunStateHelpers
  def roles
    node.run_state[:roles]
  end

  def users
    node.run_state[:users]
  end

  def nodes
    @nodes ||= Nodes.new(node)
  end
end

class Nodes
  include Enumerable

  attr_reader :node
  attr_accessor :nodes

  def initialize(node)
    @node = node
    @nodes = node.run_state[:nodes]
    # make sure we use attributes from current node instead of stale data from
    # the search index to prevent chicken-egg problems
    @nodes.delete_if { |n| n[:fqdn] == node[:fqdn] }
    @nodes << node
  end

  def each(&block)
    @nodes.each(&block)
  end

  def length
    to_a.length
  end

  def filter(&block)
    dup.tap do |obj|
      obj.nodes = @nodes.select(&block)
    end
  end

  def cluster(name)
    filter do |n|
      n.cluster_name == name rescue false
    end
  end

  def role(name)
    filter do |n|
      n.role?(name)
    end
  end
end

class Chef
  class Node
    include RunStateHelpers
  end
end
