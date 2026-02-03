#!/usr/bin/env bash

source "$HOME/.config/terraria-manager/terraria-manager.cfg"
source "$HOME/.config/terraria-manager/terraria-manager.env"
source "$TMANAGER_LIB/common.sh"

## Backup:
## Written By: Jachin Minyard
## Used to backup things like the Server, World Files, etc...
##
## Will take in three different options/flags
## Server: -s | --server
## World: -w <world name> | --world <world name>
## config: -c <config file> | --config <config file>
## Depending on the above flag this script will back up those items.


BACKUP_SERVER=false
BACKUP_WORLD=""
BACKUP_CONFIG=""


function print_usage {
    echo -e "${BOLD}TManager backup${RESET} — Backup Terraria resources"
    echo
    echo -e "${BOLD}Usage:${RESET}"
    echo -e "  ${CYAN}TManager backup${RESET} [options]"
    echo
    echo -e "${BOLD}Options:${RESET}"
    echo -e "  ${GREEN}-s${RESET}, ${GREEN}--server${RESET}               Backup the Terraria server binaries"
    echo -e "  ${GREEN}-w${RESET}, ${GREEN}--world${RESET} <world>        Backup a specific world"
    echo -e "  ${GREEN}-c${RESET}, ${GREEN}--config${RESET} <file>        Backup using a config file"
    echo -e "  ${GREEN}-h${RESET}, ${GREEN}--help${RESET}                Show this help message"
    echo
    echo -e "${BOLD}Notes:${RESET}"
    echo -e "  • At least one backup option is required"
    echo -e "  • Options may be combined"
    echo
    echo -e "${BOLD}Examples:${RESET}"
    echo -e "  ${CYAN}TManager backup${RESET} --server"
    echo -e "  ${CYAN}TManager backup${RESET} --world MyWorld"
    echo -e "  ${CYAN}TManager backup${RESET} --config server.cfg"
    echo -e "  ${CYAN}TManager backup${RESET} -s -w MyWorld"
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
    fi
    if [[ -n "$BACKUP_WORLD" ]]; then
	echo -e "${GREEN}[TManager Backup]:${RESET} Not Yet Implemented"
    fi
    if [[ -n "$BACKUP_CONFIG" ]]; then
	echo -e "${GREEN}[TManager Backup]:${RESET} Not Yet Implemented"
    fi
    
}

parse_args "$@"
run_command
