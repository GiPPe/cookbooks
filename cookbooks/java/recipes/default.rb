if gentoo?
  case node[:java][:vm]
  when /^oracle-jdk-bin-/
    package "dev-java/oracle-jdk-bin"
  else
    raise "unsupported JVM: #{node[:java][:vm]}"
  end

  package "dev-java/maven-bin"

  if root?
    execute "ensure #{node[:java][:vm]} is the system vm" do
      command "eselect java-vm set system #{node[:java][:vm]}"
      not_if { %x(eselect --brief java-vm show system).strip == node[:java][:vm] }
    end

    cookbook_file "/etc/jstatd.policy" do
      source "jstatd.policy"
      owner "root"
      group "root"
      mode "0644"
      notifies :restart, "service[jstatd]"
    end

    systemd_unit "jstatd.service"

    service "jstatd" do
      action [:enable, :start]
    end
  else
    execute "ensure #{node[:java][:vm]} is the user vm" do
      command "eselect java-vm set user #{node[:java][:vm]}"
      not_if { %x(eselect --brief java-vm show user).strip == node[:java][:vm] }
    end
  end
elsif mac_os_x?
  package "maven"
end
