module NagiosRunStateHelpers
  def nagios_nodes
    node.nodes.role("nagios")
  end

  def nagios_node
    nagios_nodes.first
  end

  def nagios_client?
    root? && nagios_nodes.any?
  end

  def nagios_client_nodes
    node.nodes
  end
end

include NagiosRunStateHelpers

class Chef
  class Recipe
    include NagiosRunStateHelpers
  end

  class Node
    include NagiosRunStateHelpers
  end

  class Resource
    include NagiosRunStateHelpers
  end
end
