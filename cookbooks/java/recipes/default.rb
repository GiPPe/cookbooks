if gentoo?
  package "dev-java/oracle-jdk-bin" do
    version "1.7*"
  end

  package "dev-java/maven-bin"

  if root?
    execute "eselect-java-vm" do
      command "eselect java-vm set system oracle-jdk-bin-1.7"
      not_if { %x(eselect --brief java-vm show system).strip == "oracle-jdk-bin-1.7" }
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
  end
elsif mac_os_x?
  package "maven"
end
