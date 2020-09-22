#!/bin/bash

export LC_ALL=C
export TZ=America/Argentina/Buenos_Aires

echo 'Stopping db...'
touch /tmp/restoring.db
kill $(ps --user mysql | grep mysql | awk '{print $1}')

echo 'Moving actual DB contento to backup/old ...'
cp -r /var/lib/mysql /usr/src/app/backup/old
rm -r /var/lib/mysql/*

echo 'Copying files...'
mariabackup --copy-back --target-dir="$@"

echo 'Fixing permissions...'
find /var/lib/mysql -type d -exec chmod 750 {} \;

echo 'Restarting container...'
rm /tmp/restoring.db