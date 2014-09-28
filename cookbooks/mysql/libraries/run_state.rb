module MysqlRunStateHelpers
  def mysql_nodes(cluster_name = node.cluster_name)
    node.nodes.cluster(cluster_name).role("mysql")
  end

  def mysql_master(cluster_name = node.cluster_name)
    master = mysql_nodes(cluster_name).filter do |n|
      n[:mysql][:server][:active_master]
    end.first
    master ||= mysql_nodes(cluster_name).first
    master
  end

  def mysql_master_connection(cluster_name = node.cluster_name)
    mysql_master(cluster_name)[:mysql][:connection] rescue nil
  end
end

include MysqlRunStateHelpers

class Chef
  class Recipe
    include MysqlRunStateHelpers
  end

  class Node
    include MysqlRunStateHelpers
  end

  class Resource
    include MysqlRunStateHelpers
  end
end
