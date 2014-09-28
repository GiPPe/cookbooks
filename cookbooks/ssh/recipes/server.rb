include_recipe "ssh"

template "/etc/ssh/sshd_config" do
  source "sshd_config"
  owner "root"
  group "root"
  mode "0644"
  notifies :reload, "service[sshd]"
end

systemd_unit "sshd.service"

service "sshd" do
  service_name "ssh" if debian_based?
  action [:enable, :start]
end

execute "root-ssh-key" do
  command "ssh-keygen -f /root/.ssh/id_rsa -N '' -C root@#{node[:fqdn]}"
  creates "/root/.ssh/id_rsa"
end

if nagios_client?
  nagios_service "SSH" do
    check_command "check_ssh!22"
    env [:testing, :development]
  end
end
