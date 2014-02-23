# chef monkey patches
class Chef
  class Node

    # implemented in chef as run_list.include?("role[#{role_name}]") which does
    # not find expanded roles *facepalm*
    def role?(role_name)
      run_list.include?("role[#{role_name}]") or (self[:roles] and self[:roles].include?(role_name))
    end

    def cluster_name
      if node[:cluster] and node[:cluster][:name]
        node[:cluster][:name]
      else
        node[:fqdn]
      end
    end

  end
end
