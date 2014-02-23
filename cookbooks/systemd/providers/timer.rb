use_inline_resources

action :create do
  nr = new_resource
  unit = nr.service

  case nr.unit
  when String
    unit = nr.unit
  when Hash
    defaults = {
      description: unit,
      command: "/bin/true",
      environment: {},
      directory: "/",
      user: "root",
      group: "root",
    }
    systemd_unit "#{nr.service}.service" do
      template "timer.service"
      cookbook "systemd"
      variables defaults.merge(nr.unit)
    end
  end

  systemd_unit "#{nr.service}.timer" do
    template "timer.unit"
    cookbook "systemd"
    variables({
      service: nr.service,
      schedule: nr.schedule,
      unit: unit,
    })
  end

  service "#{nr.service}.timer" do
    action [:enable, :start]
    only_if { systemd_running? }
  end
end

action :delete do
  nr = new_resource

  service "#{nr.service}.timer" do
    action [:disable, :stop]
    only_if { systemd_running? }
  end

  systemd_unit "#{nr.service}.timer" do
    action :delete
  end
end
