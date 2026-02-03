#!/usr/bin/env bash

## TWorld-Backup
## Written By: Jachin Minyard
##
## Backs up a specific Terraria world file.
## Enforces a per-world backup limit and removes oldest backups.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/setup.sh"
source "$SCRIPT_DIR/../utils/common.sh"
source "$TMANAGER_CONFIG/terraria-manager.cfg"

WORLD_NAME="$1"

TIMESTAMP="$(date '+%Y-%m-%d__%H-%M-%S')"
WORLD_SRC="$TERRARIA_WORLD_DIR/$WORLD_NAME"
WORLD_BASE="${WORLD_NAME%.wld}"

WORLD_BACKUP_ROOT="$TERRARIA_BACKUP_DIR/worlds/$WORLD_BASE"
BACKUP_PATH="$WORLD_BACKUP_ROOT/${WORLD_BASE}_${TIMESTAMP}.wld"


function check_backups {
    [[ -d "$WORLD_BACKUP_ROOT" ]] || return 0

    mapfile -t backups < <(
        find "$WORLD_BACKUP_ROOT" -type f -name "*.wld" -printf '%T@ %p\n' \
        | sort -n \
        | awk '{print $2}'
    )

    local count="${#backups[@]}"

    (( count <= WORLD_BAK_AMT )) && return 0

    local remove_count=$(( count - WORLD_BAK_AMT ))

    echo -e "${YELLOW}[TManager Backup]:${RESET} $count backups found, pruning $remove_count old backup(s)"

    for (( i=0; i<remove_count; i++ )); do
        echo -e "${YELLOW}[TManager Backup]:${RESET} Removing ${backups[i]}"
        rm -f -- "${backups[i]}"
    done
}


function create_backup {
    mkdir -p "$WORLD_BACKUP_ROOT"

    echo -e "${GREEN}[TManager Backup]:${RESET} Backing up world"
    echo -e "  → ${HIGHLIGHT_COLOR}$WORLD_NAME${RESET}"
    echo -e "  → ${HIGHLIGHT_COLOR}$BACKUP_PATH${RESET}"

    cp -a "$WORLD_SRC" "$BACKUP_PATH"

    echo -e "${GREEN}[TManager Backup]:${RESET} Backup complete"
}


if [[ -z "$WORLD_NAME" ]]; then
    echo -e "${ERROR_COLOR}[TManager Backup]:${RESET} No world specified"
    echo -e "Usage: ${CMD_COLOR}TManager backup --world <worldname.wld>${RESET}"
    exit 1
fi

if [[ ! -f "$WORLD_SRC" ]]; then
    echo -e "${ERROR_COLOR}[TManager Backup]:${RESET} World file not found:"
    echo -e "  → ${HIGHLIGHT_COLOR}$WORLD_SRC${RESET}"
    exit 1
fi


check_backups
create_backup
