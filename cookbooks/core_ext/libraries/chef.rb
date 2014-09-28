# chef monkey patches
class Chef
  class Node

    # implemented in chef as run_list.include?("role[#{role_name}]") which does
    # not find expanded roles *facepalm*
    def role?(role_name)
      run_list.include?("role[#{role_name}]") or (self[:roles] and self[:roles].include?(role_name))
    end

    def cluster_name
      if self[:cluster] and self[:cluster][:name]
        self[:cluster][:name]
      else
        self[:fqdn]
      end
    end

    def clustered?
      cluster_name != self[:fqdn]
    end

    def cluster?(name)
      name ? cluster_name == name : true
    end

  end
end
