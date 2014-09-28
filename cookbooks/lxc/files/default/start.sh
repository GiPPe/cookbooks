#!/bin/bash

if [[ -e /lxc/$1/rootfs/usr/lib/systemd/systemd ]]; then
	/usr/sbin/lxc-start -n $1 -- /usr/lib/systemd/systemd
else
	/usr/sbin/lxc-start -n $1
fi
