#!/usr/bin/env bash

## Backup:
## Written By: Jachin Minyard
## Used to backup things like the Server, World Files, etc...
##
## Will take in three different options/flags
## Server: -s | --server
## World: -w <world name> | --world <world name>
## config: -c <config file> | --config <config file>
## Depending on the above flag this script will back up those items.


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/setup.sh"
source "$SCRIPT_DIR/utils/common.sh"
source "$TMANAGER_CONFIG/terraria-manager.cfg"


BACKUP_SERVER=false
BACKUP_WORLD=""
BACKUP_CONFIG=""

function print_usage {
    help_title "TManager backup" "Backup Terraria resources"

    help_section "Usage"
    echo -e "  ${CMD_COLOR}TManager backup${RESET} [options]"
    echo

    help_section "Options"
    help_option "-s, --server" ""        "Backup the Terraria server binaries"
    help_option "-w, --world"  "<world>" "Backup a specific world"
    help_option "-c, --config" "<file>"  "Backup using a config file"
    help_option "-h, --help"   ""        "Show this help message"
    echo

    help_section "Notes"
    help_note "At least one backup option is required"
    help_note "Options may be combined"
    echo

    help_section "Examples"
    echo -e "  ${CMD_COLOR}TManager backup${RESET} --server"
    echo -e "  ${CMD_COLOR}TManager backup${RESET} --world MyWorld"
    echo -e "  ${CMD_COLOR}TManager backup${RESET} --config server.cfg"
    echo -e "  ${CMD_COLOR}TManager backup${RESET} -s -w MyWorld"
}


function parse_args {
    local PARSED

    # handle no args
    [[ $# -eq 0 ]] && {
	print_usage
	exit 0
    }

    # handle help arg
    for arg in "$@"; do
	case "$arg" in
            -h|--help)
		print_usage
		exit 0
		;;
	esac
    done
    
    PARSED=$(getopt -o sw:c:h \
        --long server,world:,config:,help \
        -- "$@")

    if [[ $? -ne 0 ]]; then
        echo -e "${RED}[TManager Backup]:${RESET} Invalid arguments"
        print_usage
        exit 1
    fi

    eval set -- "$PARSED"
    
    while true; do
        case "$1" in
            -s|--server)
                BACKUP_SERVER=true
                shift
                ;;
            -w|--world)
                BACKUP_WORLD="$2"
                shift 2
                ;;
            -c|--config)
                BACKUP_CONFIG="$2"
                shift 2
                ;;
            --)
                shift
                break
                ;;
            *)
                echo -e "${RED}[TManager Backup]:${RESET} Unknown option '$1'"
                print_usage
                exit 1
                ;;
        esac
    done

    ## Validation: require at least one backup target
    if [[ "$BACKUP_SERVER" == false && -z "$BACKUP_WORLD" && -z "$BACKUP_CONFIG" ]]; then
        echo -e "${RED}[TManager Backup]:${RESET} No backup target specified"
        echo -e "Use ${CYAN}-s${RESET}, ${CYAN}-w${RESET}, or ${CYAN}-c${RESET}"
        echo
        print_usage
        exit 1
    fi
}


function run_command {
    if [[ "$BACKUP_SERVER" == true ]]; then
        echo -e "${GREEN}[TManager Backup]:${RESET} Backing up server..."
        "$TMANAGER_LIB/backup_helpers/server_bak.sh"
    fi

    if [[ -n "$BACKUP_WORLD" ]]; then
        echo -e "${GREEN}[TManager Backup]:${RESET} Backing up world..."
        "$TMANAGER_LIB/backup_helpers/world_bak.sh" "$BACKUP_WORLD"
    fi

    if [[ -n "$BACKUP_CONFIG" ]]; then
        echo -e "${YELLOW}[TManager Backup]:${RESET} Config backup not yet implemented"
    fi
}


parse_args "$@"
run_command
