include_recipe "python::pip"

if gentoo?
  package "dev-python/virtualenv"
  package "dev-python/virtualenvwrapper" if zentoo?
elsif debian_based?
  package "python-virtualenv"
  python_pip "virtualenvwrapper"
elsif mac_os_x?
  python_pip "virtualenv"
  python_pip "virtualenvwrapper"
else
  raise "platform not supported"
end
