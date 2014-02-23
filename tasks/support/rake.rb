def run_task(name, *args)
  Rake::Task[name].reenable
  Rake::Task[name].invoke(*args)
end
