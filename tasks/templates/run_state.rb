module <%= name.capitalize %>Helpers
  def <%= name %>_nodes(cluster_name = node.cluster_name)
    node.run_state[:nodes].select do |n|
      n.role?("<%= name %>") && n.cluster?(cluster_name)
    end
  end
end

include <%= name.capitalize %>Helpers

class <%= name.capitalize %>
  class Recipe
    include <%= name.capitalize %>Helpers
  end

  class Node
    include <%= name.capitalize %>Helpers
  end

  class Resource
    include <%= name.capitalize %>Helpers
  end
end
