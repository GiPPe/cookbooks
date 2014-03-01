# base packages
if debian_based?
  default[:packages] = %w(
    ack
    acpitool
    apache2-utils
    atool
    autoconf
    automake
    build-essential
    bwm-ng
    colordiff
    dmidecode
    dnsutils
    dos2unix
    ethtool
    hdparm
    heirloom-mailx
    iotop
    iproute
    keychain
    less
    libxml2
    libxslt1.1
    libyaml-0-2
    lm-sensors
    lshw
    lsof
    mc
    mtr
    ncdu
    netcat
    nmap
    pciutils
    psmisc
    pwgen
    pydf
    realpath
    ruby1.9.3
    strace
    sysstat
    tcpdump
    tcptraceroute
    telnet
    traceroute
    tree
    whois
    xz-utils
  )

  if debian?
    default[:packages] += %w(
      libffi5
    )
  end

  if ubuntu?
    default[:packages] += %w(
      libffi6
    )
  end

  # system users and groups
  default[:baselayout][:groups] = {
    :root => {
      :gid => 0,
      :members => "",
    },
    :daemon => {
      :gid => 1,
      :members => "",
    },
    :bin => {
      :gid => 2,
      :members => "",
    },
    :sys => {
      :gid => 3,
      :members => "",
    },
    :adm => {
      :gid => 4,
      :members => "",
      :append => true,
    },
    :tty => {
      :gid => 5,
      :members => "",
    },
    :disk => {
      :gid => 6,
      :members => "",
    },
    :lp => {
      :gid => 7,
      :members => "",
    },
    :mail => {
      :gid => 8,
      :members => "",
      :append => true,
    },
    :news => {
      :gid => 9,
      :members => "",
    },
    :uucp => {
      :gid => 10,
      :members => "",
    },
    :man => {
      :gid => 12,
      :members => "",
    },
    :proxy => {
      :gid => 13,
      :members => "",
    },
    :kmem => {
      :gid => 15,
      :members => "",
    },
    :dialout => {
      :gid => 20,
      :members => "",
    },
    :fax => {
      :gid => 21,
      :members => "",
    },
    :voice => {
      :gid => 22,
      :members => "",
    },
    :cdrom => {
      :gid => 24,
      :members => "",
    },
    :floppy => {
      :gid => 25,
      :members => "",
    },
    :tape => {
      :gid => 26,
      :members => "",
    },
    :sudo => {
      :gid => 27,
      :members => "",
      :append => true,
    },
    :audio => {
      :gid => 29,
      :members => "",
    },
    :dip => {
      :gid => 30,
      :members => "",
    },
    :'www-data' => {
      :gid => 33,
      :members => "",
    },
    :backup => {
      :gid => 34,
      :members => "",
    },
    :operator => {
      :gid => 37,
      :members => "",
    },
    :list => {
      :gid => 38,
      :members => "",
    },
    :irc => {
      :gid => 39,
      :members => "",
    },
    :src => {
      :gid => 40,
      :members => "",
    },
    :gnats => {
      :gid => 41,
      :members => "",
    },
    :shadow => {
      :gid => 42,
      :members => "",
    },
    :utmp => {
      :gid => 43,
      :members => "",
    },
    :video => {
      :gid => 44,
      :members => "",
    },
    :sasl => {
      :gid => 45,
      :members => "",
    },
    :plugdev => {
      :gid => 46,
      :members => "",
    },
    :staff => {
      :gid => 50,
      :members => "",
    },
    :games => {
      :gid => 60,
      :members => "",
    },
    :users => {
      :gid => 100,
      :members => "",
      :append => true
    },
    :nogroup => {
      :gid => 65534,
      :members => "",
    },
  }

  default[:baselayout][:users] = {
    :daemon => {
      :uid => 1,
      :gid => 1,
      :home => "/usr/sbin",
      :shell => "/bin/sh",
    },
    :bin => {
      :uid => 2,
      :gid => 2,
      :home => "/bin",
      :shell => "/bin/sh",
    },
    :sys => {
      :uid => 3,
      :gid => 3,
      :home => "/dev",
      :shell => "/bin/sh",
    },
    :sync => {
      :uid => 4,
      :gid => 65534,
      :home => "/bin",
      :shell => "/bin/sync",
    },
    :games => {
      :uid => 5,
      :gid => 60,
      :home => "/usr/games",
      :shell => "/bin/sh",
    },
    :man => {
      :uid => 6,
      :gid => 12,
      :home => "/var/cache/man",
      :shell => "/bin/sh",
    },
    :lp => {
      :uid => 7,
      :gid => 7,
      :home => "/var/spool/lpd",
      :shell => "/bin/sh",
    },
    :mail => {
      :uid => 8,
      :gid => 8,
      :home => "/var/mail",
      :shell => "/bin/sh",
    },
    :news => {
      :uid => 9,
      :gid => 9,
      :home => "/var/spool/news",
      :shell => "/bin/sh",
    },
    :uucp => {
      :uid => 10,
      :gid => 10,
      :home => "/var/spool/uucp",
      :shell => "/bin/sh",
    },
    :proxy => {
      :uid => 13,
      :gid => 13,
      :home => "/bin",
      :shell => "/bin/sh",
    },
    :'www-data' => {
      :uid => 33,
      :gid => 33,
      :home => "/var/www",
      :shell => "/bin/sh",
    },
    :backup => {
      :uid => 34,
      :gid => 34,
      :home => "/var/backups",
      :shell => "/bin/sh",
    },
    :list => {
      :uid => 38,
      :gid => 38,
      :comment => "Mailing List Manager",
      :home => "/var/list",
      :shell => "/bin/sh",
    },
    :irc => {
      :uid => 39,
      :gid => 39,
      :comment => "ircd",
      :home => "/var/run/ircd",
      :shell => "/bin/sh",
    },
    :gnats => {
      :uid => 41,
      :gid => 41,
      :comment => "Gnats Bug-Reporting System (admin)",
      :home => "/var/lib/gnats",
      :shell => "/bin/sh",
    },
    :nobody => {
      :uid => 65534,
      :gid => 65534,
      :home => "/nonexistent",
      :shell => "/bin/sh",
    },
  }
end
