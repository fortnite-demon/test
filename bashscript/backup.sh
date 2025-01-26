#!/usr/bin/env bash

SRC_DIR=""
DEST_DIR=""
SIENCE_MODE=/usr/bin/false
ARCHIVE_SUFFIX_NAME="date +%d-%m-%Y_%H-%M-%S"
ARCHIVE_NAME="backup"
LOG_PATH="/var/log/backupsh/error.log"

usage() {
    echo "\
Usage:
  backup.sh [Options] [Arguments]

Options:
  [ -l <path-to-log-file> ]: Path to log file, default: /var/log/backupsh/error.log
  [ -d <path-to-dest-dir> ]: Dir for saved backups, default: null
  [ -b <path-to-src-dir> ]:  Which directory will we backup, default: null
  [ -s ]:                    Since mode, not print debug messages, default: false
  [ -h ]:                    Print this message" >&2
exit 1
}

log() {
    local severity="${1}"
    local message="${2}"
    local log_path="${LOG_PATH}"
    echo "[$(date +%d-%m-%Y)|$(date +%H:%M:%S.%2N)] |${severity}| ${message}" | tee -a "${log_path}" >&2
}

validate_log_file() {
    local log_file_dirname="$(dirname $LOG_PATH)"
    local log_path="${LOG_PATH}"

    # If log file exists and not access to write, script end with exit code 1
    if [[ -f $log_path ]]; then
        if [[ ! -w $log_path ]]; then
            echo "Log file [ ${log_path} ] not access to write!" >&2
            exit 1
        fi
        return 0
    fi
    # If log file is directory, script end with exit code 1
    if [[ -d $log_path ]]; then
        echo "Log file [ ${log_path} ] is directory!" >&2
        exit 1
    fi
    # If you do not have write permissions to the directory where the backup is located, script end with exit code 1.
    if [[ ! -w $log_file_dirname ]]; then
        echo "Log file directory [ ${log_file_dirname} ] not access to write!" >&2
        exit 1
    fi

    touch "${log_path}"
}

validate_dirs() {
    local dest_dir="${DEST_DIR}"
    local src_dir="${SRC_DIR}"

    # If dest dir or src dir not exists or not is directory, then exit 1
    if [[ -d $dest_dir && -d $src_dir ]]; then
        # If dest dir not perm to write or src dir not perm to read, then exit 1
        if [[ ! -w $dest_dir || ! -r $src_dir ]]; then
            log "ERROR" "dest dir: [ ${dest_dir} ] not permission to write or src dir: [ ${src_dir} ] not permission to read"
            exit 1
        fi
    else
        log "ERROR" "dest dir: [ ${dest_dir} ] or src dir: [ ${src_dir} ], not exists or not is directory"
        exit 1
    fi
}

backup() {
    local src_dir="${SRC_DIR}"
    local dest_dir="${DEST_DIR}"
    local archive_name="${ARCHIVE_NAME}-${ARCHIVE_SUFFIX_NAME}.tar.gz"
    local temp_output_file="$(mktmep --suffix=tar-output-backupsh)"

    trap "rm -rf ${temp_output_file} &> /dev/null ; exit 1" SIGINT SIGTERM SIGHUP

    log "INFO" "Start backup process... dest dir: ${dest_dir} src dir: ${src_dir}"
    tar -czvf "${dest_dir}/${archive_name}" -C "${src_dir}" . &> "${temp_output_file}"
    if [[ $? -ne 0 ]]; then
        log "CRITICAL" "BACKUP PROCESS FAILED! dest: ${dest_dir} src: ${src_dir}. TAR OUTPUT FILE: ${temp_output_file}"
        exit 1
    fi
    log "INFO" "Backup process SUCCESS! Backup: ${archive_name}, size: $(stat ${dest_dir}/${archive_name} | awk '/.*Size\:/{print $2 / 1024^3}')"

    rm -rf ${temp_output_file} &> /dev/null
}

while getopts ":l:d:b:hsn:" opt; do
    case $opt in
        l) LOG_PATH="${OPTARG}"
        ;;
        d) DEST_DIR="${OPTARG}" 
        ;;
        b) SRC_DIR="${OPTARG}"
        ;;
        h) usage
        ;;
        n) ARCHIVE_NAME="${OPTARG}"
        ;;
        s) SIENCE_MODE=/usr/bin/true
        ;;
       \?)
           echo "Invalid option [ -${OPTARG} ]" >&2
           usage
        ;;
        :)
           echo "Option [ -${OPTARG} ] required argument!" >&2
           usage
        ;;
    esac
done

if $SIENCE_MODE; then
    exec 2>/dev/null
fi

validate_log_file

validate_dirs