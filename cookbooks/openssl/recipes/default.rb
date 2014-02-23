if gentoo?
  package "dev-libs/openssl"
  package "app-misc/ca-certificates"

elsif debian_based?
  package "openssl"
  package "ca-certificates"

end

template "/etc/ssl/openssl.cnf" do
  source "openssl.cnf"
  owner "root"
  group "root"
  mode "0644"
end

directory "/usr/local/share"
directory "/usr/local/share/ca-certificates"

if root?
  # some environments (like CI or solo mode) do not have a CA
  cookbook = node.run_context.cookbook_collection['certificates']
  filenames = cookbook.relative_filenames_in_preferred_directory(node, :files, 'certificates') rescue []

  if filenames.include?("ca.crt")
    if node[:chef_domain]
      ssl_ca "/usr/local/share/ca-certificates/chef-ca"

      ssl_certificate "/etc/ssl/certs/wildcard.#{node[:chef_domain]}" do
        cn "wildcard.#{node[:chef_domain]}"
      end
    end
  else
    Chef::Log.warn("No CA certificate found. Run `rake ssl:init` to create a CA")
  end

  ruby_block "cleanup-ca-certificates" do
    block do
      Find.find('/etc/ssl/certs') do |path|
        if File.symlink?(path) and not File.exist?(path)
          File.unlink(path)
        end
      end
    end

    only_if do
      require 'find'

      result = false

      Find.find('/etc/ssl/certs') do |path|
        result = true if File.symlink?(path) and not File.exist?(path)
      end

      result
    end
  end
end

execute "update-ca-certificates"

if nagios_client?
  nagios_plugin "check_ssl_server"
end
