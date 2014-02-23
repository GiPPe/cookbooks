require 'ap'
require 'irb'
require 'ripl'

class GithubConsole
  def initialize
    Ripl.start(binding: binding)
  end

  def method_missing(name, *args, &block)
    if github.respond_to?(name)
      github.send(name, *args, &block)
    else
      super
    end
  end
end

namespace :github do

  desc "open github console"
  task :console do |t, args|
    GithubConsole.new.start
  end

  desc "fix repository settings"
  task :fix_settings do |t, args|
    org = GITHUB_ORGANIZATION
    github.repos.list(org: GITHUB_ORGANIZATION).sort_by { |r| r.name }.each do |repo|
      puts ">>> #{repo.name}"
      name = repo.name

      # assign teams
      puts "  > adding repo to team #{GITHUB_TEAM_ID}"
      github.orgs.teams.add_repo(GITHUB_TEAM_ID, org, name)

      # settings
      puts "  > updating repo settings"
      homepage = repo.homepage == 'https://github.com' ? '' : repo.homepage
      github.repos.edit(org, name, {
        name: name,
        description: repo.description,
        homepage: homepage,
        private: repo.private,
        has_issues: true,
        has_wiki: false,
        has_downloads: repo.has_downloads,
        default_branch: repo.default_branch,
      })

      # make sure hipchat is configured
      hook_ids = github.repos.hooks.list(org, name).select { |h| h[:name] == 'hipchat' }.map(&:id)
      puts "  > removing hooks #{hook_ids.inspect}"
      hook_ids.each { |hook_id| github.repos.hooks.delete(org, name, hook_id) }
      puts "  > adding HipChat hook"
      github.repos.hooks.create(org, name, {
        name: 'hipchat',
        active: true,
        config: {
          auth_token: GITHUB_HIPCHAT_TOKEN,
          room: GITHUB_HIPCHAT_ROOM,
        }
      })

      # make sure jenkins is configured
      hook_ids = github.repos.hooks.list(org, name).select { |h| h[:name] == 'jenkins' }.map(&:id)
      puts "  > removing hooks #{hook_ids.inspect}"
      hook_ids.each { |hook_id| github.repos.hooks.delete(org, name, hook_id) }
      puts "  > adding Jenkins hook"
      github.repos.hooks.create(org, name, {
        name: 'jenkins',
        active: true,
        config: {
          jenkins_hook_url: GITHUB_JENKINS_URL,
        }
      })
    end
  end

end
