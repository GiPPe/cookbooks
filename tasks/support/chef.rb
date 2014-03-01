# monkeypatch data_bag_item for better DSL
class Chef::DataBagItem
  def method_missing(sym, *args, &block)
    self.raw_data.store(sym, *args, &block)
  end
end

def cookbook_metadata
  files = [
    Dir[File.join(COOKBOOKS_DIR, "*/metadata.rb")],
    Dir[File.join(SITE_COOKBOOKS_DIR, "*/metadata.rb")],
  ].flatten.sort_by do |filename|
    File.dirname(filename)
  end

  files.map do |file|
    cookbook_path = File.dirname(file)
    cookbook_name = File.basename(cookbook_path)
    metadata = Chef::Cookbook::Metadata.new
    metadata.name(cookbook_name)
    metadata.from_file(file)
    [cookbook_name, cookbook_path, metadata]
  end
end

def search(default_query)
  ENV['QUERY'] = default_query if not ENV.key?('QUERY')
  nodes = Chef::Search::Query.new.search(:node, ENV['QUERY']).first.compact
  nodes.sort_by { |n| n[:fqdn] }.select do |node|
    next false if node[:skip] and node[:skip][:rc] # TODO: does not belong here
    if block_given?
      puts("\e[32m>>> #{node.name}\e[39m")
      yield node
    end
    true
  end
end

# overwrite knife from knife-dsl
class << eval("self", TOPLEVEL_BINDING)
  def knife(command, args)
    stdout, stderr, status = knife_capture(command, args)

    if status != 0
      puts stderr
      raise "knife #{command} #{args.join(' ')} failed"
    end

    [stdout, stderr, status]
  end
end
