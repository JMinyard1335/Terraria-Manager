#!/usr/bin/env bash

## TServer-Backup:
## Written By: Jachin Minyard
##
## Used to back up the current version of the terraria server that
## a dedicated server is running. Only a certian amount of backup
## are allowed and if there are more then that this script will delete the oldest to make
## room for the new backup. backups should be marked with the date they were made.
## server_<date>



SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/setup.sh"
source "$SCRIPT_DIR/../utils/common.sh"
source "$TMANAGER_CONFIG/terraria-manager.cfg"

## Backup directory for server backups
SERVER_BACKUP_ROOT="$TERRARIA_BACKUP_DIR/server"
TIMESTAMP="$(date '+%Y-%m-%d__%H-%M-%S')"
BACKUP_PATH="$SERVER_BACKUP_ROOT/server_$TIMESTAMP"


function check_backups {
    # if the config does not ask to prune return
    [[ -z "$TERRARIA_MAX_SERVER_BACKUPS" ]] && return 0
    (( TERRARIA_MAX_SERVER_BACKUPS <= 0 )) && return 0
    
    # Ensure backup directory exists
    [[ -d "$SERVER_BACKUP_ROOT" ]] || return 0

    # Get list of backup directories sorted oldest -> newest
    mapfile -t backups < <(
        find "$SERVER_BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' \
        | sort -n \
        | awk '{print $2}'
    )

    local count="${#backups[@]}"

    # Nothing to do if under limit
    if (( count <= TERRARIA_MAX_SERVER_BACKUPS)); then
        return 0
    fi

    local remove_count=$(( count - TERRARIA_MAX_SERVER_BACKUPS ))

    echo -e "${YELLOW}[TManager Backup]:${RESET} $count backups found, pruning $remove_count old backup(s)"
    for (( i=0; i<remove_count; i++ )); do
        echo -e "${RED}[TManager Backup]:${RESET} Removing ${backups[i]}"
        rm -rf -- "${backups[i]}"
    done
}



# copy the current server directory to the backdirectory while tagging it with the date it was created.
function create_backup {
    if [[ ! -d "$TERRARIA_SERVER_DIR" ]]; then
        echo -e "${ERROR_COLOR}[TManager Backup]:${RESET} Server directory not found"
        exit 1
    fi

    mkdir -p "$SERVER_BACKUP_ROOT"

    echo -e "${GREEN}[TManager Backup]:${RESET} Creating server backup"
    echo -e "  → ${HIGHLIGHT_COLOR}$BACKUP_PATH${RESET}"

    cp -a "$TERRARIA_SERVER_DIR" "$BACKUP_PATH"
}


function main {
    check_backups
    create_backup
    echo -e "${GREEN}[TManager Backup]:${RESET} Backup complete"
}


main
