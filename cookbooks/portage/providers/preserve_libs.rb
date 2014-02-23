use_inline_resources

action :create do
  nr = new_resource

  if root?
    directory "/etc/portage/preserve-libs.d" do
      owner "root"
      group "root"
      mode "0755"
    end

    file "/etc/portage/preserve-libs.d/#{nr.name}" do
      content "#{nr.paths.join("\n")}\n"
      owner "root"
      group "root"
      mode "0644"
    end
  end
end
