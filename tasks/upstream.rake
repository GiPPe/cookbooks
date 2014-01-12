namespace :upstream do

  desc "Initialize private repository and upstream branch"
  task :init, :repo do |t, args|
    if args.repo
      # make private repository the new origin
      sh("git remote rm origin")
      sh("git remote add origin #{args.repo}")
      sh("git push -u origin master")
    end

    # remove old cruft
    sh("git remote rm next || :")
    sh("git branch -D next || :")

    # add public cookbooks remote
    sh("git remote rm zenops || :")
    sh("git remote add -f zenops https://github.com/zenops/cookbooks.git")
    sh("git branch -t -f upstream zenops/master")
    sh("git config push.default tracking")
  end

  task :pull do
    sh("git fetch zenops")
    sh("git branch -t -f upstream zenops/master")
  end

  desc "Merge upstream branch"
  task :merge => [ :pull ]
  task :merge do
    require_clean_working_tree
    sh("git merge upstream")
  end

  desc "Show changes to upstream"
  task :changes, :branch do |t, args|
    excludes = [
      'ca/*',
      'config/hetzner.rb',
      'config/solo/*',
      'config/zendns.rb',
      'databags/*',
      'nodes/*',
      'site-cookbooks/*',
      'templates/default/user-*',
    ].map do |pat|
      "-x '*/#{pat}'"
    end.join(' ')
    sh("git diff upstream | filterdiff --clean #{excludes} | colordiff 2>/dev/null | less -R")
  end

  desc "Interactively pick changes from HEAD into upstream"
  task :pick, :upstream  do |t, args|
    base = %x(git rev-parse ":/^Merge.*'upstream'").chomp
    files = %x(git ls-tree -r --name-only upstream | grep -v ^environments).split($/)
    commits = %x(git whatchanged -r --format=oneline #{base}..HEAD -- #{files.join(' ')} | grep -v ^: | awk '{print $1}').split($/).reverse

    sh("git checkout upstream")

    commits.each do |commit|
      sh("git --no-pager log -1 #{commit}")
      puts

      sh("git show -p #{commit} || :")

      answer = ask('Do you want to pick this commit? (y/n) ') do |q|
        q.validate = /^(y|n)$/
        q.character = true
        q.echo = false
      end

      next if answer != 'y'
      puts

      %x(git cherry-pick #{commit})

      if $?.exitstatus != 0
        puts
        puts "cherry-pick failed. please merge manually."
        puts
        sh("bash")
      end
    end
  end

end

task :uc => 'upstream:changes'
task :um => 'upstream:merge'
