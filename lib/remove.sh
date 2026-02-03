#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common.sh"
source "$SCRIPT_DIR/setup.sh"
source "$TMANAGER_CONFIG/terraria-manager.cfg"

## Remove
## Written By: Jachin Minyard
## Remove is a sub command of the TManager tool
##
## Remove is used to remove the TManager tool from the users files system.
## This is a removal of the management tool not the servers or things such as world files,
## Server configs etc...

function print_usage {
    help_title "TManager remove" "Uninstall Terraria Manager"

    help_section "Usage"
    echo "  ${CMD_COLOR}TManager remove${RESET} [options]"
    echo

    help_section "Options"
    help_option "-h, --help" "" "Show this help message and exit"
    echo

    help_section "What this does"
    help_note "Removes the TManager toolchain and related configuration files"
    help_note "Deletes: ${HIGHLIGHT_COLOR}$HOME/.config/terraria-manager/${RESET}"
    help_note "Deletes: ${HIGHLIGHT_COLOR}$HOME/.local/share/terraria-manager/${RESET}"
    echo

    help_section "What this does NOT remove"
    help_note "Terraria server binaries"
    help_note "World files"
    help_note "Server configuration files"
    echo

    help_section "Example"
    echo -e "  ${CMD_COLOR}TManager remove${RESET}"
    echo
}


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
    echo -e "${BOLD}[TManager Remove]:${RESET} Uninstalling Commands..."
    
    for cmd in "${TMANAGER_CMD_LIST[@]}"; do
	if [[ -f "$TMANAGER_CMDS/$cmd" ]]; then
	    rm "$TMANAGER_CMDS/$cmd"
	    echo -e "${BOLD}[TManager Remove]:${RESET} Removed - $cmd"
	fi
    done
}


## Remove all configs from ~/.config/terraria-manager/
function uninstall_configs {
    echo -e "${BOLD}[TManager Remove]:${RESET} Removing the config files from $TMANAGER_CONFIG"
    rm -r "$TMANAGER_CONFIG"
}


## Remove the library files in ~/.local/share/terraria-manager/
function uninstall_libs {
    echo -e "${BOLD}[TManager Remove]:${RESET} Removing TManagers Library files from $TMANAGER_HOME"
    rm -r "$TMANAGER_HOME"
}


# Parse arguments
for arg in "$@"; do
    case "$arg" in
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo -e "${RED}[TManager Remove]:${RESET} Unknown option '$arg'"
            echo
            print_usage
            exit 1
            ;;
    esac
done

start_uninstall
uninstall_cmds
uninstall_libs
uninstall_configs

echo -e "${BOLD}[TManager Remove]:${RESET} Uninstall Complete."
echo "Thank you for using my tool!"



