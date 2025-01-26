#!/usr/bin/env bash

SRC_DIR=""
DEST_DIR=""
LOG_PATH="/var/log/backupsh/error.log"

usage() {
    echo "\
Usage:
  backup.sh [Options] [Arguments]

Options:
  [ -l <path-to-log-file> ]: Path to log file, default: /var/log/backupsh/error.log
  [ -d <path-to-dest-dir> ]: Dir for saved backups, default: null
  [ -b <path-to-src-dir> ]:  Which directory will we backup, default: null
  [ -h <print-help-msg> ]:   Print this message" >&2
exit 1
}

log() {
    local severity="${1}"
    local message="${2}"
    echo "[$(date +%d-%m-%Y)|$(date +%H:%M:%S.%2N)] |${severity}|: ${message}" | tee "${LOG_PATH}"
}

validate_log_file() {
    local log_file_dirname="$(dirname $LOG_PATH)"

    # If log file exists and not access to write, script end with exit code 1
    if [[ -f $LOG_PATH ]]; then
        if [[ ! -w $LOG_PATH ]]; then
            echo "Log file [ ${LOG_PATH} ] not access to write!" >&2
            exit 1
        fi
        return 0
    fi
    # If log file is directory, script end with exit code 1
    if [[ -d $LOG_PATH ]]; then
        echo "Log file [ ${LOG_PATH} ] is directory!" >&2
        exit 1
    fi
    # If you do not have write permissions to the directory where the backup is located, script end with exit code 1.
    if [[ ! -w $log_file_dirname ]]; then
        echo "Log file directory [ ${log_file_dirname} ] not access to write!" >&2
        exit 1
    fi
}

while getopts ":l:d:b:h" opt; do
    case $opt in
        l) LOG_PATH="${OPTARG}"
        ;;
        d) DEST_DIR="${OPTARG}" 
        ;;
        b) SRC_DIR="${OPTARG}"
        ;;
        h) usage
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