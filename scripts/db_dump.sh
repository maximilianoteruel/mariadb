#!/bin/bash

export LC_ALL=C
export TZ=America/Argentina/Buenos_Aires

date +"%Y-%m-%d %H:%M:%S - Starting backup dump..."

parent_dir="/usr/src/app/backup/dump"
now="$(date +%Y-%m-%d_%H-%M-%S)"

mysqldump --defaults-file=/etc/mysql/backup.cnf --all-databases --skip-lock-tables > $parent_dir/$now.sql

date +"%Y-%m-%d %H:%M:%S - Backup successful!"
printf "Backup created at %s/%s.sql\n" "${parent_dir}" "${now}"
