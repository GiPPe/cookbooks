#!/bin/bash

ip route add <%= node[:lxc][:gateway] %>/32 dev eth0
ip route add default via <%= node[:lxc][:gateway] %>
