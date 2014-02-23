systemd_unit "splunkweb.service"

service "splunkweb" do
  action [:enable, :start]
end

include_recipe "nginx"

splunk_users = Proc.new do |u|
  (u[:tags]) and
  (u[:tags].include?("hostmaster") or u[:tags].include?("splunk")) and
  (u[:password1] and u[:password1] != '!')
end

htpasswd_from_users "/etc/nginx/servers/splunk.passwd" do
  query splunk_users
  group "nginx"
  password_field :password1
end

nginx_server "splunk" do
  template "nginx.conf"
end

shorewall_rule "splunkweb" do
  destport "80,443"
end
