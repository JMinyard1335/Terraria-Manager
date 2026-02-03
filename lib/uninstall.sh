#!/usr/bin/env bash

source "$HOME/.config/terraria-manager/terraria-manager.cfg"
source "$HOME/.config/terraria-manager/terraria-manager.env"
source "$TMANAGER_LIB/common.sh"

## Uninstall
## Written By: Jachin Minyard
## Uninstall is a sub command of the TManager tool
##
## Uninstall is used to remove the TManager tool from the users files system.
## This is a removal of the management tool not the servers or things such as world files,
## Server configs etc...


function start_uninstall {
    echo "Welcome to the TManager Uninstaller."
    echo
    echo -e "${BOLD}${UNDERLINE}${RED}!!! STOP  READ CAREFULY !!!${RESET}"
    echo -e "This ${BOLD}${UNDERLINE}WILL${RESET} uninstall the TManager tool chain and all related configs!"
    echo -e "This ${BOLD}${UNDERLINE}WILL${RESET} remove the '$HOME/.config/terraria-manager/' folder and all its contents"
    echo -e "This ${BOLD}${UNDERLINE}WILL NOT${RESET} remove:\n\t- Server\n\t- world files\n\t- server configs"
    echo
    if ! y_n_prompt "If you are sure you would like to proceed? (${GREEN}Y${RESET}/${RED}n${RESET}): "; then
	echo "Uninstaller Cancelled!"
	exit 0
    fi
}


## Remove all the commands from the ~/.local/bin/
function uninstall_cmds {
    echo -e "${BOLD}[TManager Uninstall]:${RESET} Uninstalling Commands..."
    
    for cmd in "${TMANAGER_CMD_LIST[@]}"; do
	if [[ -f "$TMANAGER_CMDS/$cmd" ]]; then
	    rm "$TMANAGER_CMDS/$cmd"
	    echo "[TManager Uninstall]: Removed - $cmd"
	fi
    done
}


## Remove all configs from ~/.config/terraria-manager/
function uninstall_configs {
    echo -e "${BOLD}[TManager Uninstall]:${RESET} Removing the config files from $TMANAGER_CONFIG"
    rm -r "$TMANAGER_CONFIG"
}


## Remove the library files in ~/.local/share/terraria-manager/
function uninstall_libs {
    echo "${BOLD}[TManager Uninstall]:${RESET} Removing TManagers Library files from $TMANAGER_HOME"
    rm -r "$TMANAGER_HOME"
}

start_uninstall
uninstall_cmds
uninstall_libs
uninstall_configs

echo -e "${BOLD}[TManager Uninstall]:${RESET} Uninstall Complete."
echo "Thank you for using my tool!"



