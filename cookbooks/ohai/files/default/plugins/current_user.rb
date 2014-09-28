Ohai.plugin(:CurrentUser) do
  provides 'current_user'

  collect_data do
    require 'etc'
    current_user Etc.getlogin
  end
end
