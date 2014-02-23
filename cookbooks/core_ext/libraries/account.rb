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
    node.run_state[:users].select do |u|
      users.include?(u[:id].to_sym) and
        u[:authorized_keys] and
        not u[:authorized_keys].empty?
    end.map do |u|
      u[:authorized_keys]
    end.flatten.tap do |keys|
      if node[:authorize_vagrant_public_key]
        keys << "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
      end
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
