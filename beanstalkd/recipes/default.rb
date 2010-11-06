package "app-misc/beanstalkd"

service "beanstalkd" do
  action :enable
end

template "/etc/conf.d/beanstalkd" do
  source "beanstalkd.confd.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "beanstalkd")
end

if tagged?("nagios-client")
  portage_package_keywords "=dev-perl/Beanstalk-Client-1.06"
  portage_package_keywords "=dev-perl/Nagios-Plugin-Beanstalk-0.04"

  package "dev-perl/Nagios-Plugin-Beanstalk"

  node.default[:nagios][:services]["BEANSTALKD"][:enabled] = true
end
