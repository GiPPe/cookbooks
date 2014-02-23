template "/etc/nsswitch.conf" do
  source "nsswitch.conf"
  owner "root"
  group "root"
  mode "0644"
end

if gentoo?
  template "/etc/pam.d/system-auth" do
    source "system-auth.pamd"
    owner "root"
    group "root"
    mode "0644"
  end

  template "/etc/pam.d/system-login" do
    source "system-login.pamd"
    owner "root"
    group "root"
    mode "0644"
  end

elsif debian_based?
  # do not touch debians pam for now
end
