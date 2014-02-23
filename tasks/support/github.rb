begin
  require 'github_api'
rescue LoadError
  $stderr.puts "GitHub API cannot be loaded. Skipping some rake tasks ..."
end

begin
  require File.expand_path('config/github', TOPDIR)
  [GITHUB_ORGANIZATION]
rescue LoadError, Exception
  $stderr.puts "GitHub settings cannot be loaded. Skipping some rake tasks ..."
end

def github
  return @github unless @github.nil?
  username = ask("Username: ")
  password = ask("Password: ") { |q| q.echo = false }
  @github = Github.new({
    basic_auth: "#{username}:#{password}",
    auto_pagination: true,
  })
end
