#!/bin/bash

BACKUP_DIR="/var/opt/chef-server/backup"

usage() {
  echo "Usage: chef-backup [--backup] [--restore]"
}

backup() {
  set -e
  set -x

  # Create folders
  mkdir -p ${BACKUP_DIR}
  mkdir -p ${BACKUP_DIR}/nginx
  mkdir -p ${BACKUP_DIR}/bookshelf
  mkdir -p ${BACKUP_DIR}/postgresql

  # Backup of files
  cp -a /var/opt/chef-server/nginx/{ca,etc} ${BACKUP_DIR}/nginx
  cp -a /var/opt/chef-server/bookshelf/data ${BACKUP_DIR}/bookshelf

  # Backup of database
  su - opscode-pgsql -c "/opt/chef-server/embedded/bin/pg_dump -c opscode_chef" > ${BACKUP_DIR}/opscode_chef.sql
}


restore() {
  set -e
  set -x

  chef-server-ctl reconfigure
  /opt/chef-server/embedded/bin/psql -U opscode-pgsql opscode_chef < ${BACKUP_DIR}/opscode_chef.sql
  chef-server-ctl stop

  cp -a ${BACKUP_DIR}/nginx/{ca,etc} /var/opt/chef-server/nginx/
  cp -a ${BACKUP_DIR}/bookshelf/data /var/opt/chef-server/bookshelf/

  chef-server-ctl start
  sleep 30
  chef-server-ctl reindex
}

if [[ ! -x /opt/chef-server/embedded/bin/pg_dump ]];then
  echo "Chef Server 11 not found!"
  exit 1
fi

if [[ $(id -u) -ne 0 ]]; then
  echo "You need to be root"
  exit 1
fi

while [ "$#" -gt 0 ] ; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --backup)
      action="backup"
      shift 1
      ;;
    --restore)
      action="restore"
      break
      ;;
    *)
      usage
      exit 1
      ;;

    esac
  done

  if [[ ${action} == "backup" ]];then
    backup
  elif [[ ${action} == "restore" ]];then
    restore
  else
    usage
    exit 1
  fi
