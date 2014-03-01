#!/usr/bin/env ruby

require 'json'
require 'date'
require 'webhdfs'

$client = WebHDFS::Client.new('localhost', 50070)

def clean_directory(path, mtime)
  $client.list(path).each do |entry|
    subpath = File.join(path, entry['pathSuffix'])
    if entry['type'] == 'DIRECTORY'
      clean_directory(subpath, mtime)
      subfiles = $client.list(subpath)
      if subfiles.empty?
        puts "deleting empty folder: #{subpath}"
        $client.delete(subpath)
      else
        puts "skipping non-empty folder: #{subpath}"
      end
    else
      if entry['modificationTime'] < mtime
        puts "deleting old file: #{subpath}"
        $client.delete(subpath)
      end
    end
  end
end

clean_directory("/tmp", (Time.now.to_i - 5 * 24 * 60 * 60) * 1000)
clean_directory("/user", (Time.now.to_i - 60 * 24 * 60 * 60) * 1000)
