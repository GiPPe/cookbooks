require 'listen'

CHEF_ZERO_IGNORE = [
  %r{vagrant/machines},
  %r{\.swp$},
]

desc "Start chef-zero and upload changes automatically"
task :zero do
  exec("chef-zero -H 0.0.0.0 -p 3099") if fork.nil?
  sleep 1
  puts "Uploading repository ..."
  knife :upload, ['/', '-s', 'http://localhost:3099']
  puts "Waiting for changes ..."
  Listen.to(TOPDIR, ignore: CHEF_ZERO_IGNORE) do |m, a, r|
    start = Time.now.to_f
    puts "Uploading changes ..."
    knife :upload, ['/', '-s', 'http://localhost:3099']
    puts "... took #{(Time.now.to_f - start).round(2)}s"
  end
  Process.waitall
end
