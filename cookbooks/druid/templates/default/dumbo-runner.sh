#!/bin/bash

# Run in UTC
export TZ="/usr/share/zoneinfo/UTC"
export JRUBY_OPTS="-J-Xmx4g"
unset RUBYOPTS

source ~/.rvm/scripts/rvm

export PATH=<%= node[:druid][:hadoop][:path] %>:$PATH

while true; do
  cd /var/app/dumbo/current || exit 1

  (
    flock -n 9 || exit 1
    ./dumbo.rb
  ) 9>/var/app/dumbo/run.lock

  # spawn hadoop
  for conf in /var/app/dumbo/*.druid; do
    /var/app/dumbo/bin/batch-druid-job.sh $conf &
    sleep 10
  done

  sleep 60
done
