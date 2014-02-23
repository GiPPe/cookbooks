#!/bin/bash

# Run in UTC
export TZ="/usr/share/zoneinfo/UTC"

unset RUBYOPTS

source ~/.rvm/scripts/rvm

PATH+=":/opt/hadoop/bin"

cd /var/app/dumbo/current || exit 1

while true; do
  (
    flock -n 9 || exit 1
    ./dumbo.rb
  ) 9>/var/app/dumbo/run.lock

  # spawn hadoop
  for conf in /var/app/dumbo/current/*.druid; do
    /var/app/dumbo/bin/batch-druid-job.sh $conf &
    sleep 10
  done

  sleep 60
done
