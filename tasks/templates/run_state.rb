module <%= name.capitalize %>Helpers
  def <%= name %>_nodes(cluster_name = node.cluster_name)
    node.nodes.cluster(cluster_name).role("<%= name %>")
  end
end

include <%= name.capitalize %>Helpers

class Chef
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
