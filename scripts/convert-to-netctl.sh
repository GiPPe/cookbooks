#!/bin/bash

device=${1:-eth0}

ipaddress=$(ip addr show dev ${device} | grep 'inet .*global' | awk '{ print $2 }' | awk -F/ '{ print $1 }')
gateway=$(ip route list | grep default.*${device} | awk '{ print $3 }')

emerge netctl

cat >> /etc/netctl/${device} << EOF
Description='${device}'
Interface=${device}
Connection=ethernet
ForceConnect=yes
IP=static
Address=('${ipaddress}/32')
Routes=('${gateway}')
Gateway='${gateway}'
DNS=('8.8.8.8' '8.8.4.4')
EOF

netctl enable ${device}
