#!/bin/bash

umount -l /mnt/* 2>&1 > /dev/null

vgchange -a n
echo -ne "vgremove vg\ny\ny\ny\ny\ny\ny\ny\ny\ny\nquit\n" | lvm 2>&1 > /dev/null
vgreduce --removemissing vg

for i in /dev/md*; do
    mdadm -S $i 2>&1 > /dev/null
done

for x in /dev/sd*; do
    mdadm --zero-superblock $x 2>&1 > /dev/null
done

for x in /dev/sd[a-z]; do
    parted -s $x mklabel gpt
done

partprobe

cd /tmp
wget -q -O quickstart.tar.gz https://github.com/zentoo/quickstart/tarball/master
tar -xzf quickstart.tar.gz
cd *-quickstart-*
exec ./quickstart -v -d profiles/<%= args.profile %>.sh
