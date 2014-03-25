module ChefRunStateHelpers
  def chef_client_nodes
    node.run_state[:nodes].select do |n|
      n[:fqdn] and
      n[:cluster] and
      n[:cluster][:name] == node[:cluster][:name]
    end
  end
end

include ChefRunStateHelpers

class Chef
  class Recipe
    include ChefRunStateHelpers
  end

  class Node
    include ChefRunStateHelpers
  end

  class Resource
    include ChefRunStateHelpers
  end
end
