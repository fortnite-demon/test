#!/usr/bin/env bash

SRC_DIR=""
DEST_DIR=""
LOG_PATH="/var/log/backupsh/error.log"

usage() {
    echo "
Usage:
  backup.sh [Options] [Arguments]

Options:
  [ -l <path-to-log-file> ]: Path to log file, default: /var/log/backupsh/error.log
  [ -d <path-to-dest-dir> ]: Dir for saved backups, default: null
  [ -b <path-to-src-dir> ]:  Which directory will we backup, default: null
" >&2
}

log() {
    local severity="${1}"
    local message="${2}"
    echo "[$(date +%d-%m-%Y)|$(date +%H:%M:%S.%2N)] |${severity}|: ${message}" | tee "${LOG_PATH}"
}

while getopts ":l:d:b:" opt; do
    case $opt in
        l) LOG_PATH="${OPTARG}"
        ;;
        d) DEST_DIR="${OPTARG}" 
        ;;
        b) SRC_DIR="${OPTARG}"
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