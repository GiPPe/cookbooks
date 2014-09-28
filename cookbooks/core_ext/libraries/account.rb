module AccountHelpers
  def get_user(user)
    pwent = Etc.getpwnam(user)
    user = Mash[pwent.members.zip(pwent.values)]

    pwent = Etc.getgrgid(user[:gid])
    user[:group] = Mash[pwent.members.zip(pwent.values)]

    user
  rescue
    {}
  end

  def authorized_keys_for(users)
    users.map! { |u| u.to_sym }
    node.users.select do |u|
      users.include?(u[:id].to_sym) and
        u[:authorized_keys] and
        not u[:authorized_keys].empty?
    end.map do |u|
      u[:authorized_keys]
    end
  end
end

include AccountHelpers

class Chef
  class Recipe
    include AccountHelpers
  end

  class Node
    include AccountHelpers
  end

  class Resource
    include AccountHelpers
  end
end
