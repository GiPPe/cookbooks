# remote commands for maintenance

namespace :rc do

  desc "Update gentoo packages"
  task :updateworld do
    search("platform:gentoo") do |node|
      run_task('node:updateworld', node.name)
    end
  end

  desc "Open interactive shell"
  task :shell do
    search("*:*") do |node|
      if ENV.key?('NOSUDO')
        system("ssh -t #{node.name}'")
      else
        system("ssh -t #{node.name} '/usr/bin/sudo -i'")
      end
    end
  end

  desc "Reboot machines and wait until they are up"
  task :reboot do
    search("default_query:does_not_exist") do |node|
      reboot_wait(node.name)
      puts "Sleeping 5 minutes to slow down reboot loop"
      sleep 5*60
    end
  end

end
