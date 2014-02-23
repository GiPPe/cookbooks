directory "/opt/splunk/etc/apps/SplunkForNagios" do
  action :delete
  recursive true
  not_if { File.directory?("/opt/splunk/etc/apps/SplunkForNagios/.git") }
end

git "/opt/splunk/etc/apps/SplunkForNagios" do
  repository "https://github.com/zenops/splunk-for-nagios"
  reference "master"
  action :sync
end
