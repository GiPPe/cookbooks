include Gentoo::Portage::PackageConf

action :create do
  manage_package_conf(:create, "keywords", new_resource)
end

action :delete do
  manage_package_conf(:delete, "keywords", new_resource)
end
