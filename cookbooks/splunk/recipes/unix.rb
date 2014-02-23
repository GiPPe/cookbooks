directory "/opt/splunk/etc/apps/Splunk_TA_nix" do
  action :delete
  recursive true
  notifies :restart, "service[splunk]" if splunk_forwarder?
end

directory "/opt/splunk/etc/apps/SA-nix" do
  action :delete
  recursive true
end

directory "/opt/splunk/etc/apps/splunk_app_for_nix" do
  action :delete
  recursive true
end
