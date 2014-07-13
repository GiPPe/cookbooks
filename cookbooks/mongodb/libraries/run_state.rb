module MongodbRunStateHelpers
  def mongo_configdb_nodes(name)
    node.nodes.role("mongo-configdb").select do |n|
      n[:mongodb][:cluster] == name
    end
  end
end

include MongodbRunStateHelpers

class Chef
  class Recipe
    include MongodbRunStateHelpers
  end

  class Node
    include MongodbRunStateHelpers
  end

  class Resource
    include MongodbRunStateHelpers
  end
end
