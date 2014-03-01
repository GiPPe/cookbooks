default[:camus][:git][:repository] = "https://github.com/linkedin/camus"
default[:camus][:git][:revision] = "camus-kafka-0.8"

default[:camus][:topics] = nil
default[:camus][:decoder] = nil
default[:camus][:writer] = nil

default[:camus][:etl][:destination] = "/history"
default[:camus][:etl][:base_path] = "/camus/running"
default[:camus][:etl][:history_path] = "/camus/state"
