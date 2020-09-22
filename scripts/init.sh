#!/bin/bash

export LC_ALL=C
export TZ=America/Argentina/Buenos_Aires


if [ -z ${BACKUP_DISABLED+x} ]; then
    
    if [ -z ${CRON_DB_DUMP+x} ]; then
        date +"%Y-%m-%d %H:%M:%S - Environment Variable CRON_DB_DUMP is not defined. Setting to CRON_DB_DUMP=30_2_15_*_*"
        CRON_DB_DUMP="30_2_15_*_*"
    fi
    
    
    if [ -z ${CRON_DB+x} ]; then
        date +"%Y-%m-%d %H:%M:%S - Environment Variable CRON_DB is not defined. Setting to CRON_DB=0_2_*_*_*"
        CRON_DB="0_2_*_*_*"
    fi
    
    date +"%Y-%m-%d %H:%M:%S - Configuring Cron..."
    
    crontab_config="/etc/cron.d/crontab"
    touch $crontab_config
    
    echo "${CRON_DB_DUMP//_/ } root /usr/src/app/scripts/db_dump.sh >> /usr/src/app/log/cron.log 2>&1" >> $crontab_config
    echo "${CRON_DB//_/ } root /usr/src/app/scripts/db_incremental_backup.sh >> /usr/src/app/log/cron.log 2>&1" >> $crontab_config
    echo "#" >> $crontab_config
    chmod 0600 $crontab_config
    
    date +"%Y-%m-%d %H:%M:%S - Configuring Credentials..."
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
