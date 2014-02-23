directory "/opt/splunk/etc/apps/Splunk_TA_hadoopops" do
  action :delete
  recursive true
  notifies :restart, "service[splunk]" if splunk_forwarder?
end

directory "/opt/splunk/etc/apps/SA-HadoopOps" do
  action :delete
  recursive true
end

directory "/opt/splunk/etc/apps/splunk_for_hadoopops" do
  action :delete
  recursive true
end
