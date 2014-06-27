if gentoo?
  package "dev-util/debootstrap"
elsif debian_based?
  package "debootstrap"
end

directory "/usr/share/keyrings" do
  owner "root"
  group "root"
  mode "0755"
end

# gentoo does not ship the ubuntu keyring, so we download it for good measure
remote_file "/usr/share/keyrings/ubuntu-archive-keyring.gpg" do
  source "http://archive.ubuntu.com/ubuntu/project/ubuntu-archive-keyring.gpg"
  checksum "60438aafe7cffb3bb0370435c63a47ea6d44c533d0ec53df7ec6832f554e5930"
end
