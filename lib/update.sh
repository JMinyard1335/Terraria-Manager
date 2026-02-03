#!/usr/bin/env bash

## Update
## Written By: Jachin Minyard
##
## Safely updates the Terraria dedicated server by:
## 1. Backing up the current server
## 2. Installing the latest server build
## 3. Applying Pi-specific fixes if configured

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/setup.sh"
source "$SCRIPT_DIR/common.sh"
source "$TMANAGER_CONFIG/terraria-manager.cfg"

function print_usage {
    help_title "TManager update" "Update the Terraria dedicated server"

    help_section "Usage"
    echo -e "  ${CMD_COLOR}TManager update${RESET}"
    echo

    help_section "Notes"
    help_note "This will BACK UP the existing server before updating"
    help_note "Worlds and configs are not affected"
    help_note "Uses Pi-safe install if RASPI=true in config"
    echo
}

function start_update {
    echo -e "${YELLOW}${BOLD}WARNING:${RESET}"
    echo -e "This will update the Terraria server binaries."
    echo -e "A backup will be created before proceeding."
    echo

    if ! y_n_prompt "Continue with update? (${GREEN}Y${RESET}/${RED}n${RESET}): "; then
        echo -e "${YELLOW}[TManager Update]:${RESET} Update cancelled"
        exit 0
    fi
}

function run_update {
    echo -e "${GREEN}[TManager Update]:${RESET} Backing up server..."
    if ! TManager backup --server; then
        echo -e "${ERROR_COLOR}[TManager Update]:${RESET} Backup failed — aborting update"
        exit 1
    fi

    echo -e "${GREEN}[TManager Update]:${RESET} Installing updated server..."

    if [[ "$RASPI" == true ]]; then
        TManager install -f --pi
    else
        TManager install -f 
    fi
}

start_update
run_update

echo -e "${GREEN}[TManager Update]:${RESET} Update complete"
