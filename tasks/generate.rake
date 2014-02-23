require "highline/import"

namespace :generate do

  desc "Generate a cookbook skeleton"
  task :cookbook do
    name = ask('Cookbook name: ') do |q|
      q.validate = /^\w+$/
    end

    description = ask('Cookbook description: ')
    platforms = ask('Cookbook platforms: ').split(/\s/)
    platforms = %w(gentoo) if platforms.empty?

    maintainer = %x(git config user.name).chomp
    maintainer_email = %x(git config user.email).chomp

    b = binding()
    erb = Erubis::Eruby.new(File.read(File.join(TEMPLATES_DIR, 'metadata.rb')))

    cb_path = File.join(COOKBOOKS_DIR, name)
    FileUtils.mkdir_p(cb_path)

    File.open(File.join(cb_path, "metadata.rb"), "w") do |f|
      f.puts(erb.result(b))
    end

    FileUtils.mkdir_p(File.join(cb_path, "recipes"))

    %w(files templates).each do |d|
      FileUtils.mkdir_p(File.join(cb_path, d, "default"))
    end

    File.open(File.join(cb_path, "recipes", "default.rb"), "w") do |f|
      f.write "# add some resources here\n"
    end
  end

  desc "Generate the production environment"
  task :env do
    %w(production staging).each do |env|
      b = binding()
      erb = Erubis::Eruby.new(File.read(File.join(TEMPLATES_DIR, 'environment.json')))
      File.open(File.join(ENVIRONMENTS_DIR, "#{env}.json"), "w") do |f|
        f.puts(erb.result(b))
      end
    end
  end

  desc "Generate a default OpenVPN/Tunnelblick config"
  task :tunnelblick do
    remote = "chef." + URI.parse(Chef::Config[:chef_server_url]).host.split('.')[1..-1].join('.')
    login = Chef::Config[:node_name]

    b = binding()
    erb = Erubis::Eruby.new(File.read(File.join(TEMPLATES_DIR, 'openvpn.conf')))

    tmpdir = Dir.mktmpdir
    path = File.join(tmpdir, "#{COMPANY_NAME} VPN.tblk")
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
