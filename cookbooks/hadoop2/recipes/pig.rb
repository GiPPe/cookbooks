include_recipe "hadoop2"

%w(
  /var/app/hadoop2/pig
  /var/app/hadoop2/pig/contrib
).each do |dir|
  directory dir do
    owner "hadoop2"
    group "root"
    mode "0775"
  end
end

pig_tar = "http://www.eu.apache.org/dist/pig/pig-#{node[:hadoop2][:pig][:version]}/pig-#{node[:hadoop2][:pig][:version]}-src.tar.gz"
pig_dir = "/var/app/hadoop2/pig/pig-#{node[:hadoop2][:pig][:version]}-src"

# bug fix, remove when ant runs w/o it (or dependencies change)
remote_file "/var/app/hadoop2/.m2/repository/org/mortbay/jetty/jetty/6.1.26/jetty-6.1.26.zip" do
  source "https://repository.jboss.org/nexus/content/groups/public/org/mortbay/jetty/jetty/6.1.26/jetty-6.1.26-bundle.zip"
  user "hadoop2"
  group "hadoop2"
end

tar_extract pig_tar do
  target_dir "/var/app/hadoop2/pig"
  creates pig_dir
  user "hadoop2"
  group "hadoop2"

  notifies :run, "execute[pig-build]"
end

execute "pig-build" do
  cwd pig_dir
  command "/usr/bin/ant clean jar-withouthadoop -Dhadoopversion=23" #TODO: make that configurable again
  user "hadoop2"
  group "hadoop2"
end

contrib_jars = Hash[node[:hadoop2][:pig][:default_jars].map do |contrib_uri|
  [contrib_uri, "/var/app/hadoop2/pig/contrib/#{contrib_uri.split('/')[-1]}"]
end]

# Deploy contrib jars
contrib_jars.each do |contrib_uri, jar_name|
  remote_file jar_name do
    source contrib_uri

    user "hadoop2"
    group "hadoop2"
  end
end

# Clean contrib folder, only leave only node[:hadoop2][:pig][:default_jars]
Dir["/var/app/hadoop2/pig/contrib/*"].each do |file_name|
  unless contrib_jars.values.include? file_name
    file file_name do
      action :delete
    end
  end
end

template "/var/app/hadoop2/current/bin/pig" do
  source "pig.sh"
  owner "root"
  group "hadoop2"
  mode "0755"
end
