# encoding: utf-8

require 'rubygems'

if Process.euid > 0
  begin
    require 'bundler'
  rescue LoadError
    $stderr.puts "Bundler could not be loaded. Please make sure to run ./scripts/bootstrap"
    exit(1)
  end
  Bundler.setup if defined?(Bundler)
end

# The top of the repository checkout
ROOT = File.expand_path("..", __FILE__)
CONFIG_FILE = File.expand_path(File.join(ROOT, ".chef", "config.rb"))

# directories for entities
BAGS_DIR = File.expand_path(File.join(ROOT, "data_bags"))
COOKBOOKS_DIR = File.expand_path(File.join(ROOT, "cookbooks"))
ENVIRONMENTS_DIR = File.expand_path(File.join(ROOT, "environments"))
SITE_COOKBOOKS_DIR = File.expand_path(File.join(ROOT, "site-cookbooks"))
TEMPLATES_DIR = File.expand_path(File.join(ROOT, "tasks", "templates"))

# Directories needed by the SSL tasks
SSL_CA_DIR = File.expand_path(File.join(ROOT, "ca"))
SSL_CERT_DIR = File.expand_path(File.join(ROOT, "site-cookbooks/certificates/files/default/certificates"))
SSL_CONFIG_FILE = File.expand_path(File.join(ROOT, ".chef", "openssl.cnf"))

require 'liquid/boot'

require 'chef'
require 'json'

# make rake more silent
RakeFileUtils.verbose_flag = false
Chef::Log.level = :error

# load chef config
begin
  Chef::Config.from_file(CONFIG_FILE)
rescue
  # do nothing
end

# support files
Dir[ File.join(File.dirname(__FILE__), 'tasks', 'support', '*.rb') ].sort.each do |f|
  require f
end

# tasks
Dir[ File.join(File.dirname(__FILE__), 'tasks', '*.rake') ].sort.each do |f|
  load f
end
