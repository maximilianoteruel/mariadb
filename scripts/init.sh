#!/bin/bash

export LC_ALL=C
export TZ=America/Argentina/Buenos_Aires

if [[ -z "${BACKUP_DISABLED}" ]]; then
    date +"%Y-%m-%d %H:%M:%S - Configuring Environment..."
    touch /etc/mysql/backup.cnf
    echo "[client]" >> /etc/mysql/backup.cnf
    echo "user=root" >> /etc/mysql/backup.cnf
    echo "password=$MYSQL_ROOT_PASSWORD" >> /etc/mysql/backup.cnf
    
    date +"%Y-%m-%d %H:%M:%S - Starting Cron..."
    cron
fi

date +"%Y-%m-%d %H:%M:%S - Starting DB..."
docker-entrypoint.sh mysqld >> /usr/src/app/log/mysql.log 2>&1

while [ -f /tmp/restoring.db ]; do date +"%Y-%m-%d %H:%M:%S - Restoring DB..."; sleep 10s; done;
