require 'chef/knife'

module KnifeSudo
  class Sudo < Chef::Knife

    deps do
      require 'chef/search/query'
      require 'chef/knife/ssh'
      Chef::Knife::Ssh.load_deps
    end

    banner "knife sudo QUERY COMMAND (options)"

    option :concurrency,
      :short => "-C NUM",
      :long => "--concurrency NUM",
      :description => "The number of concurrent connections",
      :default => 10,
      :proc => lambda { |o| o.to_i }

    option :query,
      :short => "-Q VALUE",
      :long => "--query VALUE",
      :description => "Solr query for node search (default: *:*)",
      :default => "*:*"

    def run
      if name_args.size == 0
        $stderr.puts "No command given."
        exit 1
      end

      command = "/usr/bin/sudo -i /usr/bin/env LANG=en_US.UTF-8 #{name_args.join(' ')}"

      knife_ssh = Chef::Knife::Ssh.new
      knife_ssh.name_args = [config[:query], command]
      knife_ssh.config[:manual] = false
      knife_ssh.config[:concurrency] = config[:concurrency] unless config[:concurrency] == 0
      knife_ssh.run
    end
  end
end
