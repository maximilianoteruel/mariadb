#!/bin/bash

export LC_ALL=C
export TZ=America/Argentina/Buenos_Aires

number_of_args="${#}"
# Check whether any arguments were passed
if [ "${number_of_args}" != 1 ]; then
    error "Script requires one folder as an argument."
fi


folder="/usr/src/app/backup/$@/restore"
cd "${folder}"
shopt -s nullglob
incremental_dirs=( ./incremental-*/ )
full_dirs=( ./full-*/ )
shopt -u nullglob



log_file="prepare-progress.log"
full_backup_dir="${full_dirs[0]}"

# Use this to echo to standard error
error() {
    printf "%s: %s\n" "$(basename "${BASH_SOURCE}")" "${1}" >&2
    exit 1
}

trap 'error "An unexpected error occurred.  Try checking the \"${log_file}\" file for more information."' ERR

sanity_check () {
    # Check whether a single full backup directory are available
    if (( ${#full_dirs[@]} != 1 )); then
        error "Exactly one full backup directory is required."
    fi
}

do_backup () {
    # Apply the logs to each of the backups
    printf "Initial prep of full backup %s\n" "${full_backup_dir}"
    mariabackup --prepare --target-dir="${full_backup_dir}"
    
    for increment in "${incremental_dirs[@]}"; do
        printf "Applying incremental backup %s to %s\n" "${increment}" "${full_backup_dir}"
        mariabackup --prepare --incremental-dir="${increment}" --target-dir="${full_backup_dir}"
    done
    
    printf "Applying final logs to full backup %s\n" "${full_backup_dir}"
    mariabackup --prepare --target-dir="${full_backup_dir}"
}

sanity_check && do_backup > "${log_file}" 2>&1

# Check the number of reported completions.  Each time a backup is processed,
# an informational "completed OK" and a real version is printed.  At the end of
# the process, a final full apply is performed, generating another 2 messages.
ok_count="$(grep -c 'completed OK' "${log_file}")"

if (( ${ok_count} == ${#full_dirs[@]} + ${#incremental_dirs[@]} + 1 )); then
    cat << EOF
Backup looks to be fully prepared.  Please check the "prepare-progress.log" file to verify before continuing.
If everything looks correct, you can apply the restored files running:
./scripts/db_incremental_restore.sh ${PWD}/$(basename "${full_backup_dir}")

EOF
else
    error "It looks like something went wrong.  Check the \"${log_file}\" file for more information."
fi
