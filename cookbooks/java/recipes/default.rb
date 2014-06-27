if gentoo?
  package "dev-java/oracle-jdk-bin"
  package "dev-java/maven-bin"

  # super ugly
  latest = "eselect --brief --color=no java-vm list| head -n-1 | tail -n1 | awk '{print $1}'"

  if root?
    execute "eselect-java-vm" do
      command "eselect java-vm set system $(#{latest})"
      not_if { %x(eselect --brief java-vm show system).strip == %x(#{latest}) }
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
    execute "eselect-java-vm" do
      command "eselect java-vm set user $(#{latest})"
      not_if { %x(eselect --brief java-vm show user).strip == %x(#{latest}) }
    end
  end
elsif mac_os_x?
  package "maven"
end
