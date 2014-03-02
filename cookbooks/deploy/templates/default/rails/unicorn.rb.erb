# -*- ruby -*-
# Sample verbose configuration file for Unicorn
#
# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# documentation.

# Use at least one worker per core if you're on a dedicated server,
# more will usually help for _short_ waits on databases/caches.
worker_processes <%= @worker_processes %>

# nuke workers after 30 seconds instead of 60 seconds (the default)
timeout <%= @timeout %>

# Help ensure your application will always spawn in the symlinked
# "current" directory that Capistrano sets up.
working_directory "<%= @path %>/current"

# Location of the pidfile. Should not be changed unless you
# know what you are doing.
pid "<%= @path %>/shared/pids/unicorn.pid"

# In production we want clean logging
logger(Logger.new($stderr).tap do |log|
  log.formatter = proc { |severity, datetime, progname, msg| "#{msg.to_s}\n" }
end)

# listen on Unix domain socket and let nginx proxy
listen "<%= @path %>/shared/pids/unicorn.sock"

# combine REE with "preload_app true" for memory savings
# http://rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
preload_app true

if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end

# this is required to make bundler use the correct Gemfile in case unicorn is
# upgraded via USR2. otherwise the symlink will be expanded and old Gemfiles
# may be used after upgrade.
before_exec do |server|
  ENV["BUNDLE_GEMFILE"] = "<%= @path %>/current/Gemfile"
end

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  # This allows a new master process to incrementally
  # phase out the old master process with SIGTTOU to avoid a
  # thundering herd (especially in the "preload_app false" case)
  # when doing a transparent upgrade.  The last worker spawned
  # will then kill off the old master process with a SIGQUIT.
  old_pid = "<%= @path %>/shared/pids/unicorn.pid.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  # the following is *required* for Rails + "preload_app true",
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end

  # if preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis.  TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls)
end
