if splunk6_forwarder?
  if gentoo?
    package "net-analyzer/splunkforwarder"

  elsif debian_based?
    remote_file "#{Chef::Config[:file_cache_path]}/splunkforwarder-6.0.1-189883-linux-2.6-amd64.deb" do
      source "http://download.splunk.com/releases/6.0.1/universalforwarder/linux/splunkforwarder-6.0.1-189883-linux-2.6-amd64.deb"
      mode "0644"
      checksum "0ff311aed26a1788b3d0eb0f162eb21591e2b092d1cacc20591d298de2790873"
    end

    dpkg_package "splunkforwarder" do
      source "#{Chef::Config[:file_cache_path]}/splunkforwarder-6.0.1-189883-linux-2.6-amd64.deb"
      action :install
    end

    link "/opt/splunk" do
      to "/opt/splunkforwarder"
    end
  end

  include_recipe "splunk6::common"
end
