module MongodbRunStateHelpers
  def mongo_configdb_nodes(name)
    node.run_state[:nodes].select do |n|
      n.role?("mongo-configdb") and
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
