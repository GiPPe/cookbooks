module PostfixRunStateHelpers
  def postfix_networks
    node.nodes.map do |n|
      n[:ipaddress]
    end + node[:postfix][:mynetworks]
  end

  def postfix_relayhost
    node.nodes.role("mx").first
  end
end

include PostfixRunStateHelpers

class Chef
  class Recipe
    include PostfixRunStateHelpers
  end

  class Node
    include PostfixRunStateHelpers
  end

  class Resource
    include PostfixRunStateHelpers
  end
end
