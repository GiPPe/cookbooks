module PostgresqlRunStateHelpers
  def postgresql_nodes(cluster_name = node.cluster_name)
    node.nodes.cluster(cluster_name).role("postgresql")
  end

  def postgresql_master(cluster_name = node.cluster_name)
    master = postgresql_nodes(cluster_name).filter do |n|
      n[:postgresql][:server][:active_master]
    end.first
    master ||= postgresql_nodes(cluster_name).first
    master
  end

  def postgresql_master_connection(cluster_name = node.cluster_name)
    postgresql_master(cluster_name)[:postgresql][:connection] rescue nil
  end
end

include PostgresqlRunStateHelpers

class Chef
  class Recipe
    include PostgresqlRunStateHelpers
  end

  class Node
    include PostgresqlRunStateHelpers
  end

  class Resource
    include PostgresqlRunStateHelpers
  end
end
