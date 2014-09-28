module JavaHelpers
  def mvn_project_version(path)
    %x{cd #{path} && /usr/bin/mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version | grep -v '\\[' | grep -v Download}.strip
  end

  def log4j_std_appenders
    %q{# configure stdout appender
log4j.appender.stdout = org.apache.log4j.ConsoleAppender
log4j.appender.stdout.Threshold = INFO
log4j.appender.stdout.Target = System.out
log4j.appender.stdout.layout = org.apache.log4j.PatternLayout
log4j.appender.stdout.layout.ConversionPattern = [%c] %m%n
log4j.appender.stdout.filter.filter1=org.apache.log4j.varia.LevelRangeFilter
log4j.appender.stdout.filter.filter1.levelMin=INFO
log4j.appender.stdout.filter.filter1.levelMax=INFO

# configure stderr appender
log4j.appender.stderr = org.apache.log4j.ConsoleAppender
log4j.appender.stderr.Threshold = WARN
log4j.appender.stderr.Target = System.err
log4j.appender.stderr.layout = org.apache.log4j.PatternLayout
log4j.appender.stderr.layout.ConversionPattern = [%c] %m%n}
  end
end

include JavaHelpers

class Chef
  class Recipe
    include JavaHelpers
  end

  class Node
    include JavaHelpers
  end

  class Resource
    include JavaHelpers
  end
end

