#!/usr/bin/env bash

## Uninstall
## Written By: Jachin Minyard
## Used to remove the Terraria Server
##
## Removes the terraria server from the installed path
## Makes a backup before removing unless --clean | -c
## is specified.


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/setup.sh"
source "$SCRIPT_DIR/utils/common.sh"
source "$TMANAGER_CONFIG/terraria-manager.cfg"


CLEAN=false


## Prints a help page.
function print_usage {
    help_title "TManager uninstall" "Remove the Terraria dedicated server"

    help_section "Usage"
    echo -e "  ${CMD_COLOR}TManager uninstall${RESET} [options]"
    echo

    help_section "Options"
    help_option "-c, --clean" "" "Remove server files without creating a backup"
    help_option "-h, --help"  "" "Show this help message"
    echo

    help_section "Notes"
    help_note "By default, the server is backed up before removal"
    help_note "Only server binaries are removed — worlds and configs are preserved"
    echo

    help_section "Examples"
    echo -e "  ${CMD_COLOR}TManager uninstall${RESET}"
    echo -e "  ${CMD_COLOR}TManager uninstall --clean${RESET}"
}


## Parses all the arguments provided.
function parse_args {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -c|--clean)
                CLEAN=true
                shift
                ;;
            -h|--help)
                print_usage
                exit 0
                ;;
            *)
                echo -e "${ERROR_COLOR}[TManager Uninstall]:${RESET} Unknown option '$1'"
                echo -e "See ${CMD_COLOR}--help${RESET} for usage"
                exit 1
                ;;
        esac
    done
}

## Prompt the user to make sure they wanted to uninstall the server.
function start_uninstall {
    echo -e "${RED}${BOLD}!! WARNING !!${RESET}"
    echo -e "This will remove the Terraria server from:"
    echo -e "  ${HIGHLIGHT_COLOR}$TERRARIA_SERVER_DIR${RESET}"
    echo

    if [[ "$CLEAN" == true ]]; then
        echo -e "${YELLOW}• No backup will be created${RESET}"
    else
        echo -e "${GREEN}• A backup will be created before removal${RESET}"
    fi

    echo
    if ! y_n_prompt "Are you sure you want to continue? (Y/n): "; then
        echo -e "${YELLOW}Uninstall cancelled.${RESET}"
        exit 0
    fi
}


function uninstall {
    if [[ ! -d "$TERRARIA_SERVER_DIR" ]]; then
        echo -e "${YELLOW}[TManager Uninstall]:${RESET} No server installation found"
        exit 0
    fi

    if [[ "$CLEAN" == false ]]; then
        echo -e "${GREEN}[TManager Uninstall]:${RESET} Creating server backup"
        TManager backup --server
    fi

    echo -e "${RED}[TManager Uninstall]:${RESET} Removing server files"
    rm -rf "$TERRARIA_SERVER_DIR"

    echo -e "${GREEN}[TManager Uninstall]:${RESET} Server successfully removed"
}


parse_args "$@"
start_uninstall
uninstall
