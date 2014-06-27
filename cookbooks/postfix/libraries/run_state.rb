module PostfixRunStateHelpers
  def postfix_networks
    node.run_state[:nodes].map do |n|
      n[:ipaddress]
    end + node[:postfix][:mynetworks]
  end

  def postfix_relayhost
    node.run_state[:nodes].select do |n|
      n.role?("mx")
    end.first
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
