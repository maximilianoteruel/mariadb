#!/bin/bash

export LC_ALL=C
export TZ=America/Argentina/Buenos_Aires

date +"%Y-%m-%d %H:%M:%S - Starting backup..."

days_of_backups=3  # Must be less than 7
parent_dir="/usr/src/app/backup"
todays_dir="${parent_dir}/$(date +%Y_%m)"
log_file="${todays_dir}/backup-progress.log"
now="$(date +%Y-%m-%d_%H-%M-%S)"
processors="$(nproc --all)"

# Use this to echo to standard error
error () {
    printf "%s: %s\n" "$(basename "${BASH_SOURCE}")" "${1}" >&2
    exit 1
}

trap 'error "An unexpected error occurred."' ERR

set_options () {
    # List the xtrabackup arguments
    xtrabackup_args=(
        "--defaults-file=/etc/mysql/backup.cnf"
        "--backup"
        "--parallel=${processors}"
        "--extra-lsndir=${todays_dir}"
        "--stream=xbstream"
    )
    
    backup_type="full"
    
    # Add option to read LSN (log sequence number) if a full backup has been
    # taken today.
    if grep -q -s "to_lsn" "${todays_dir}/xtrabackup_checkpoints"; then
        backup_type="incremental"
        lsn=$(awk '/to_lsn/ {print $3;}' "${todays_dir}/xtrabackup_checkpoints")
        xtrabackup_args+=( "--incremental-lsn=${lsn}" )
    fi
}


take_backup () {
    # Make sure today's backup directory is available and take the actual backup
    mkdir -p "${todays_dir}"
    find "${todays_dir}" -type f -name "*.incomplete" -delete
    mariabackup "${xtrabackup_args[@]}" --target-dir="${todays_dir}" > "${todays_dir}/${backup_type}-${now}.xbstream.incomplete" 2> "${log_file}"
    
    mv "${todays_dir}/${backup_type}-${now}.xbstream.incomplete" "${todays_dir}/${backup_type}-${now}.xbstream"
}

set_options && take_backup

# Check success and print message
if tail -1 "${log_file}" | grep -q "completed OK"; then
    date +"%Y-%m-%d %H:%M:%S - Backup successful!"
    date +"%Y-%m-%d %H:%M:%S - Backup created at ${todays_dir}/${backup_type}-${now}.xbstream"
else
    date +"%Y-%m-%d %H:%M:%S - Backup failure!"
    error "Check ${log_file} for more information"
fi