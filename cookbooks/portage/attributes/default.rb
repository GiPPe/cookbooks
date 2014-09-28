# paths & directories
default[:portage][:arch] = %x(portageq envvar ARCH 2>/dev/null || :).chomp
default[:portage][:make_conf] = "/etc/portage/make.conf"
default[:portage][:confdir] = "/etc/portage"
default[:portage][:portdir] = "/usr/portage"
default[:portage][:distdir] = "#{node[:portage][:portdir]}/distfiles"
default[:portage][:pkgdir] = "#{node[:portage][:portdir]}/packages/#{node[:portage][:arch]}"

# compiler settings
default[:portage][:CFLAGS] = "-O2 -pipe"
default[:portage][:CXXFLAGS] = "${CFLAGS}"

# build-time flags
default[:portage][:USE] = []

# advanced masking
default[:portage][:ACCEPT_KEYWORDS] = nil

# advanced features
default[:portage][:FEATURES] = %w(buildpkg)
default[:portage][:OPTS] = %w(--usepkg=y --getbinpkg=y)
default[:portage][:MAKEOPTS] = "-j1"
default[:portage][:overlays] = []

# repo settings
if gentoo?
  default[:portage][:repo] = File.read("/usr/portage/profiles/repo_name").chomp

  if node[:portage][:repo] =~ /^zentoo/
    default[:portage][:profile] = "#{node[:portage][:portdir]}/profiles/default/linux/#{node[:portage][:arch]}/zentoo"
    default[:portage][:SYNC] = "rsync://mirror.zenops.net/zentoo-portage"
    default[:portage][:BINHOST] = "http://mirror.zenops.net/zentoo/${ARCH}/packages"
    default[:portage][:MIRRORS] = %w(
    http://mirror.zenops.net/zentoo
    http://ftp.spline.de/pub/gentoo
    )
  elsif node[:portage][:repo] == "gentoo"
    default[:portage][:profile] = "#{node[:portage][:portdir]}/profiles/default/linux/#{node[:portage][:arch]}/13.0"
    default[:portage][:SYNC] = "rsync://rsync.de.gentoo.org/gentoo-portage"
    default[:portage][:MIRRORS] = %w(
    http://ftp.spline.de/pub/gentoo
    )
  else
    raise "unsupported portage repo: #{node[:portage][:repo]}"
  end
end
