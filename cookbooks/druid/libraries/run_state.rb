module DruidHelpers
  def druid_version
    @druid_version ||= mvn_project_version("/var/app/druid/current")
  end
end

include DruidHelpers

class Chef
  class Recipe
    include DruidHelpers
  end

  class Node
    include DruidHelpers
  end

  class Resource
    include DruidHelpers
  end
end
