module NagiosRunStateHelpers
  def nagios_nodes
    node.run_state[:nodes].select do |n|
      n.role?("nagios")
    end
  end

  def nagios_node
    nagios_nodes.first
  end

  def nagios_client?
    root? && nagios_nodes.any?
  end

  def nagios_client_nodes
    node.run_state[:nodes]
  end
end

include NagiosRunStateHelpers

class Nagios
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
