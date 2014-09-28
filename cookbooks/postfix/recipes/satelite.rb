if postfix_relayhost && !node[:skip][:postfix_satelite]
  include_recipe "postfix"
  include_recipe "postfix::adminforward"
  include_recipe "postfix::tls"

  smtpd_recipient_restrictions = %w(
    check_recipient_access\ hash:/etc/postfix/recipient
    permit_mynetworks
    reject_unauth_destination
    permit
  )

  postconf "relay all mail via relayhost" do
    set({
      relayhost: postfix_relayhost[:ipaddress],
      mydestination: "",
      inet_interfaces: "loopback-only",
      smtpd_recipient_restrictions: smtpd_recipient_restrictions.join(", "),
    })
  end

  if nagios_client?
    nrpe_command "check_postfix_satelite" do
      command "/usr/lib/nagios/plugins/check_smtp -H #{postfix_relayhost[:ipaddress]} -t 60 -C 'MAIL FROM: <root@#{node[:fqdn]}>' -R '250 2.1.0 Ok' -C 'RCPT TO: <unhollow@gmail.com>' -R '250 2.1.5 Ok'"
    end

    nagios_service "POSTFIX-SATELITE" do
      check_command "check_nrpe!check_postfix_satelite"
      env [:testing, :development]
    end
  end
end
