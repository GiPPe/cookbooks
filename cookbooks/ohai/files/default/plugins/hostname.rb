#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Benjamin Black (<nostromo@gmail.com>)
# Author:: Bryan McLellan (<btm@loftninjas.org>)
# Author:: Daniel DeLeo (<dan@kallistec.com>)
# Author:: Doug MacEachern (<dougm@vmware.com>)
# Author:: James Gartrell (<jgartrel@gmail.com>)
# Copyright:: Copyright (c) 2008, 2009 Opscode, Inc.
# Copyright:: Copyright (c) 2009 Bryan McLellan
# Copyright:: Copyright (c) 2009 Daniel DeLeo
# Copyright:: Copyright (c) 2010 VMware, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'socket'
require 'ipaddr'

Ohai.plugin(:Hostname) do
  provides "domain", "hostname", "fqdn", "machinename"

  # hostname : short hostname
  # machinename : output of hostname command (might be short on solaris)
  # fqdn : result of canonicalizing hostname using DNS or /etc/hosts
  # domain : domain part of FQDN
  #
  # hostname and machinename should always exist
  # fqdn and domain may be broken if DNS is broken on the host

  def from_cmd(cmd)
    so = shell_out(cmd)
    so.stdout.split($/)[0]
  end

  # forward and reverse lookup to canonicalize FQDN (hostname -f equivalent)
  # this is ipv6-safe, works on ruby 1.8.7+
  def resolve_fqdn
    hostname = from_cmd("hostname")
    addrinfo = Socket.getaddrinfo(hostname, nil).first
    iaddr = IPAddr.new(addrinfo[3])
    Socket.gethostbyaddr(iaddr.hton)[0]
  rescue
    hostname
  end

  def collect_domain
    # Domain is everything after the first dot
    if fqdn
      fqdn =~ /.+?\.(.*)/
      domain $1
    end
  end

  def collect_hostname
    # Hostname is everything before the first dot
    if machinename
      machinename =~ /([^.]+)/
      hostname $1
    elsif fqdn
      fqdn =~ /([^.]+)/
      hostname $1
    end
  end

  collect_data(:darwin, :default) do
    machinename from_cmd("hostname")
    fqdn resolve_fqdn
    collect_hostname
    collect_domain
  end

  collect_data(:linux) do
    machinename from_cmd("hostname")
    fqdn from_cmd("hostname -f")
    collect_hostname
    collect_domain
  end
end
