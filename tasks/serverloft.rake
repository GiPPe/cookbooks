require_relative 'support/serverloft'

begin
  require File.expand_path('config/serverloft', TOPDIR)
  [SERVERLOFT_WEB_USERNAME, SERVERLOFT_WEB_PASSWORD, SERVERLOFT_WEB_EMAIL]
rescue LoadError, Exception
  $stderr.puts "Serverloft credentials cannot be loaded. Skipping some rake tasks ..."
end

namespace :serverloft do
  desc "Hardware reset Serverloft hosted machine"
  task :reset, :fqdn do |t, args|
    sl_task(args.fqdn, SERVERLOFT_WEB_USERNAME, SERVERLOFT_WEB_PASSWORD, SERVERLOFT_WEB_EMAIL, 'reset')
    wait_for_ssh(args.fqdn)
  end
  desc "Reboot in recovery mode or back to normal (toggle) Serverloft hosted machine"
  task :recovery, :fqdn do |t, args|
    sl_task(args.fqdn, SERVERLOFT_WEB_USERNAME, SERVERLOFT_WEB_PASSWORD, SERVERLOFT_WEB_EMAIL, 'recovery')
    wait_for_ssh(args.fqdn)
    $stdout.puts "The password is: '#{SERVERLOFT_WEB_PASSWORD}'"
  end
end
