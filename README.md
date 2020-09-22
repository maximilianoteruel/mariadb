**_ MariaDB _**

Docker de base de datos MariaDB con las siguientes caracteristicas:

Variables de Entorno:

```
- CRON_DB_DUMP=30_2_15_*_*
- CRON_DB=0_2_*_*_*
- BACKUP_DISABLED=1
```

\*\* Backups automaticos en el directorio /usr/src/app/backup:

- el dia 1 de cada mes a las 2am nuevo Full (/usr/src/app/backup)
- todos los dias a las 2am nuevo Incremental (/usr/src/app/backup)
- el dia 15 de cada mes a las 2:30am nuevo Dump (/usr/src/app/backup/dump)
- si se desea deshabilitar definir la variable de entorno BACKUP_DISABLED=1

\*\* Logs de Cron y DB en archivos, en el docker solo se muestra las inicializaciones

- /usr/src/app/log/cron.log
- /usr/src/app/log/mysql.log

Recuperar backup:

- extraer el directorio completo en donde esta el backup q se desea utilizar

```
  /usr/src/app/scripts/db_incremental_extract.sh 2020_07
```

- borrar los directorios dentro de restore que no se desean, dejar el full + ultimo directorio el backup correspondiente a la fecha q se desea utilizar

```
  /usr/src/app/scripts/db_incremental_prepare.sh 2020_07
```

- restaurar db, seguir instrucciones que responde el script con los comandos necesarios

```
  /usr/src/app/scripts/db_incremental_restore.sh /usr/src/app/backup/2020_07/restore/full-07-08-2020_17-58-44
```
