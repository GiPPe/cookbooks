begin
  require 'knife/dsl'
  require 'benchmark'
  require 'active_support/core_ext/hash/indifferent_access'
rescue LoadError
  $stderr.puts "Knife DSL cannot be loaded. Skipping some rake tasks ..."
end
