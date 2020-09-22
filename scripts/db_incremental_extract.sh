#!/bin/bash

export LC_ALL=C
export TZ=America/Argentina/Buenos_Aires

number_of_args="${#}"
# Check whether any arguments were passed
if [ "${number_of_args}" != 1 ]; then
    error "Script requires one folder as an argument."
fi

processors="$(nproc --all)"
folder="/usr/src/app/backup"
log_file="$folder/$@/restore/extract-progress.log"

cd "${folder}"
mkdir -p "./$@/restore"

# Use this to echo to standard error
error () {
    printf "%s: %s\n" "$(basename "${BASH_SOURCE}")" "${1}" >&2
    exit 1
}


trap 'error "An unexpected error occurred.  Try checking the \"${log_file}\" file for more information."' ERR


do_extraction () {
    string_extract="$folder/$@/*.xbstream"
    for file in ${string_extract}; do
        base_filename="$(basename "${file%.xbstream}")"
        restore_dir="./$@/restore/${base_filename}"
        
        printf "\n\nExtracting file %s\n\n" "${file}"
        
        # Extract the directory structure from the backup file
        mkdir --verbose -p "${restore_dir}"
        mbstream -x -C "${restore_dir}" < "${file}"
        
        
        printf "\n\nFinished work on %s\n\n" "${file}"
        
    done > "${log_file}" 2>&1
}

do_extraction "$@"

printf "Extraction complete! Backup directories have been extracted to the \"restore\" directory.\n"

