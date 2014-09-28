require "highline/import"

namespace :generate do

  desc "Generate a cookbook skeleton"
  task :cookbook do
    name = ask('Cookbook name: ') do |q|
      q.validate = /^[-\w]+$/
    end

    description = ask('Cookbook description: ')
    platforms = ask('Cookbook platforms: ').split(/\s/)
    platforms = %w(gentoo) if platforms.empty?

    maintainer = %x(git config user.name).chomp
    maintainer_email = %x(git config user.email).chomp

    b = binding()

    cb_path = File.join(COOKBOOKS_DIR, name)
    FileUtils.mkdir_p(File.join(cb_path, "attributes"))
    FileUtils.mkdir_p(File.join(cb_path, "files/default"))
    FileUtils.mkdir_p(File.join(cb_path, "libraries"))
    FileUtils.mkdir_p(File.join(cb_path, "providers"))
    FileUtils.mkdir_p(File.join(cb_path, "recipes"))
    FileUtils.mkdir_p(File.join(cb_path, "resources"))
    FileUtils.mkdir_p(File.join(cb_path, "templates/default"))

    erb = Erubis::Eruby.new(File.read(File.join(TEMPLATES_DIR, 'metadata.rb')))
    File.open(File.join(cb_path, "metadata.rb"), "w") do |f|
      f.puts(erb.result(b))
    end

    erb = Erubis::Eruby.new(File.read(File.join(TEMPLATES_DIR, 'run_state.rb')))
    File.open(File.join(cb_path, "libraries/run_state.rb"), "w") do |f|
      f.puts(erb.result(b))
    end

    File.open(File.join(cb_path, "recipes", "default.rb"), "w") do |f|
      f.write "# add some resources here\n"
    end
  end

  desc "Generate a default OpenVPN/Tunnelblick config"
  task :tunnelblick do
    remote = "vpn." + URI.parse(Chef::Config[:chef_server_url]).host.split('.')[1..-1].join('.')
    login = Chef::Config[:node_name]

    b = binding()
    erb = Erubis::Eruby.new(File.read(File.join(TEMPLATES_DIR, 'openvpn.conf')))

    tmpdir = Dir.mktmpdir
    path = File.join(tmpdir, "#{$conf.company.name} VPN.tblk")
    FileUtils.mkdir_p(path)

    File.open(File.join(path, "config.ovpn"), "w") do |f|
      f.puts(erb.result(b))
    end

    FileUtils.cp(File.join(SSL_CERT_DIR, "ca.crt"),
                 File.join(path, "ca.crt"))
    FileUtils.cp(File.join(SSL_CERT_DIR, "#{login}.crt"),
                 File.join(path, "#{login}.crt"))
    FileUtils.cp(File.join(SSL_CERT_DIR, "#{login}.key"),
                 File.join(path, "#{login}.key"))

    puts ">>> Configuration is at #{path}"
    system("open '#{path}' || :")
  end

end
