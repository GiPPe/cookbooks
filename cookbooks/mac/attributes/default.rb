if ::File.exist?("#{node[:homedir]}/.storerc")
  storerc = ::File.read("#{node[:homedir]}/.storerc").split
  default[:apple_id] = storerc.first
  default[:apple_password] = storerc.last
end

default[:mac][:packages] = %w(
  ack
  atool
  autoconf
  automake
  colordiff
  dos2unix
  findutils
  gawk
  gnu-sed
  gnu-tar
  icu4c
  libffi
  libksba
  libtool
  libxml2
  libxslt
  libyaml
  ncdu
  netcat
  nmap
  openssl
  pkg-config
  pwgen
  readline
  sqlite
  tree
  wget
)
