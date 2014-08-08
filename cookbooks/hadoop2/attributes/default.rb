default[:hadoop2][:version] = "2.4.1"

default[:hadoop2][:cluster] = nil # defaulted to node.cluster_name by recipe
default[:hadoop2][:rack_id] = nil # defaulted to "/default-rack/#{node.cluster_name}"

default[:hadoop2][:tmp_dir] = "/var/tmp/hadoop2"
default[:hadoop2][:java_tmp] = "/var/tmp/java"

default[:hadoop2][:nodemanager][:memory_mb] = 8192

default[:hadoop2][:pig][:version] = "0.12.1"
default[:hadoop2][:pig][:default_jars] = %w{
  http://search.maven.org/remotecontent?filepath=com/googlecode/json-simple/json-simple/1.1.1/json-simple-1.1.1.jar
  http://search.maven.org/remotecontent?filepath=com/twitter/elephantbird/elephant-bird-pig/4.4/elephant-bird-pig-4.4.jar
  http://search.maven.org/remotecontent?filepath=com/twitter/elephantbird/elephant-bird-hadoop-compat/4.4/elephant-bird-hadoop-compat-4.4.jar
  http://search.maven.org/remotecontent?filepath=com/twitter/parquet-pig-bundle/1.4.1/parquet-pig-bundle-1.4.1.jar
  http://search.maven.org/remotecontent?filepath=org/apache/pig/piggybank/0.12.0/piggybank-0.12.0.jar
  http://search.maven.org/remotecontent?filepath=mysql/mysql-connector-java/5.1.29/mysql-connector-java-5.1.29.jar
}

default[:hadoop2][:fs][:s3][:access_key] = nil
default[:hadoop2][:fs][:s3][:secret_key] = nil

default[:hadoop2][:du][:reserved] = 0
default[:hadoop2][:decommissioning] = []
