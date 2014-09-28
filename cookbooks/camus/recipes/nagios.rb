if nagios_client?
  nagios_plugin "check_camus" do
    source "check_camus.rb"
  end
end
