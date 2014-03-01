begin
  require 'mechanize'
  @agent = Mechanize.new
  @agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  @agent.user_agent_alias = 'Linux Firefox'
rescue LoadError
  $stderr.puts "Mecahnize cannot be loaded"
end

def auth(user, pass)
  # CSRF on every step...
  token = @agent.get("https://my.serverloft.de/en/Generic/Auth/Index/login").form.field_with(:name => 'formToken').value

  @agent.post("https://my.serverloft.de/en/Generic/Auth/Index/login", {
    'formToken' => token,
    'password' =>  pass,
    'username' => user
  })
end

def get_sl_name(lm_name)
  # Figure out real server name
  data = @agent.get("https://my.serverloft.de/en/Dedicated/Contract/Index/server").search(
    "//div[@title='#{lm_name}']/../../td/text()").text

  if data.include?('Recovery mode active')
    sl_name = data.sub(/Recovery mode active/, '')
    $is_in_recovery = true
  else
    sl_name = data
  end

  if sl_name.empty? || sl_name.nil?
   $stderr.puts "Couldn't figure out server name, giving up"
   exit 1
  else
   return sl_name
  end
end

def get_prepare_token(sl_name, mode)
  token = @agent.get("https://my.serverloft.de/en/Dedicated/#{mode}/Index/prepare", {
    'server_name' => sl_name,
  }).form.field_with(:name => 'formToken').value

  return token
end

def reset(sl_name)
  prepare_token = get_prepare_token(sl_name, 'Reboot')

  token = @agent.post("https://my.serverloft.de/en/Dedicated/Reboot/Index/reinsurance", {
    'confirm' => 'Next',
    'formToken' => prepare_token,
    'reboot_method' => 'HWR'
  }).form.field_with(:name => 'formToken').value

  success = @agent.post("https://my.serverloft.de/en/Dedicated/Reboot/Index/save", {
    'confirm' => 'Reboot server',
    'formToken' => token,
    'reboot_method' => 'HWR'
  })

  if !success.body.include?("server reboot will be carried out")
    $stderr.puts "Unable to reboot the machine"
    exit 1
  end
end

def recovery_start(email, pass, sl_name)
  $stderr.puts "Rebooting in recovery mode"
  prepare_token = get_prepare_token(sl_name, 'Recovery')

  token = @agent.post("https://my.serverloft.de/en/Dedicated/Recovery/Index/prepare", {
    'email' => email,
    'formToken' => prepare_token,
    'next' => 'Next',
    'password' => pass,
    'password_repeat' => pass
  }).form.field_with(:name => 'formToken').value

  success = @agent.post("https://my.serverloft.de/en/Dedicated/Recovery/Index/save", {
    'confirm' => 'Start Recovery',
    'email' => email,
    'formToken' => token,
    'password' => pass,
    'password_repeat' => pass
  })

  if !success.body.include?("server will be restarted in recovery mode")
    $stderr.puts "Unable to restart in recovery mode"
    exit 1
 end
end

def recovery_stop(sl_name)
  $stdout.puts "Rebooting back to normal from recovery"

  token = @agent.get("https://my.serverloft.de/en/Dedicated/Recovery/Index/cancel", {
    'server_name' => sl_name
  }).form.field_with(:name => 'formToken').value

  success = @agent.post("https://my.serverloft.de/en/Dedicated/Recovery/Index/cancel", {
    'cancel' => 'Stop recovery',
    'formToken' => token
  })

  if !success.body.include?("being restarted in normal mode")
    $stderr.puts "Unable to restart in normal mode or machine is not in recovery mode"
    exit 1
  end
end

def sl_task(fqdn, user, pass, email, mode)
  # We use bottom-level of domain name for alias on Serverloft
  # lm_name = fqdn[/[^\.]+/]
  lm_name = fqdn
  auth(user, pass)
  sl_name = get_sl_name(lm_name)

  case mode
  when "reset"
    reset(sl_name)
  when "recovery"
    if !defined? $is_in_recovery
      recovery_start(email, pass, sl_name)
    else
      recovery_stop(sl_name)
    end
  end
end
