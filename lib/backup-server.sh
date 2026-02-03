#!/usr/bin/env bash

source "$HOME/.config/terraria-manager/terraria-manager.cfg"

## TServer-Backup:
## Written By: Jachin Minyard
##
## Used to back up the current version of the terraria server that
## a dedicated server is running. Only a certian amount of backup
## are allowed and if there are more then that this script will delete the oldest to make
## room for the new backup. backups should be marked with the date they were made.
## server_<date>

function check_backups {
    # Ensure backup directory exists
    [[ -d "$BACKUP_DIR" ]] || return 0

    # Get list of backup directories sorted oldest -> newest
    mapfile -t backups < <(
        find "$BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' \
        | sort -n \
        | awk '{print $2}'
    )

    local count="${#backups[@]}"

    # Nothing to do if under limit
    if (( count <= TSERVER_BAK_AMT )); then
        return 0
    fi

    local remove_count=$(( count - TSERVER_BAK_AMT ))

    echo "[BACKUP LOG]: $count backups found, removing $remove_count old backup(s)"

    for (( i=0; i<remove_count; i++ )); do
        echo "[BACKUP LOG]: Removing ${backups[i]}"
        rm -rf -- "${backups[i]}"
    done
}



# copy the current server directory to the backdirectory while tagging it with the date it was created.
function create_backup {
    local backup_dir="$BACKUP_DIR/server_$(date '+%Y-%m-%d_%H-%M-%S')"

    mkdir -p "$backup_dir"
    cp -r "$(dirname "$SERVER_DIR")" "$backup_dir/"
}


function main {
    check_backups
    create_backup
}


main
