#!/usr/bin/env bash

source "$HOME/.config/terraria-manager/terraria-manager.cfg"
source "$HOME/.config/terraria-manager/terraria-manager.env"
source "$TMANAGER_LIB/common.sh"

## Launch:
## Written By Jachin Minyard
## Used to launch instances of Terraria Server.
##
## This ones pretty simple it is just a wrapper around tmux mono and Terraria Server
## simply put its arguments and options are the same as TerrariaServer and will be passed
## accordling. A Session name must be provided so that tmux can give each session running a
## a server a name for finding it quickly later.


#region Variables
SERVER_ARGS=()
PORT=""
WORLD=""
MAX_PLAYERS=""
PASSWORD=""
MOTD=""
AUTOCREATE=""
BANLIST=""
WORLD_NAME=""
LOBBY=""
IP_ADDR=""
FORCE_PRIORITY=""
ANNOUNCE_RANGE=""
SEED=""
SECURE=false
NOUPNP=false
STEAM=false
DISABLE_ANNOUNCE=false

#endregion Variables


#region Functions
## Prints out a simple help menu for this command.
function print_usage {
    echo -e "${BOLD}TManager launch${RESET} — Launch a Terraria server instance"
    echo
    echo -e "${BOLD}Usage:${RESET}"
    echo -e "  ${CYAN}TManager launch${RESET} ${GREEN}--session${RESET} <name> [TerrariaServer options]"
    echo
    echo -e "${BOLD}Required:${RESET}"
    echo -e "  ${GREEN}-s${RESET}, ${GREEN}--session${RESET} <name>       Name of the tmux session to run the server in"
    echo
    echo -e "${BOLD}Common Options:${RESET}"
    echo -e "  ${GREEN}-c${RESET}, ${GREEN}--config${RESET} <file>        Use a Terraria server config file"
    echo -e "  ${GREEN}--port${RESET} <number>               Server port"
    echo -e "  ${GREEN}--world${RESET} <path>                Path to world file"
    echo -e "  ${GREEN}--players${RESET} <number>            Max players (alias: --maxplayers)"
    echo -e "  ${GREEN}--password${RESET} <password>         Server password"
    echo -e "  ${GREEN}--motd${RESET} <text>                 Message of the day"
    echo
    echo -e "${BOLD}World Creation:${RESET}"
    echo -e "  ${GREEN}--autocreate${RESET} <1|2|3>           Create world if missing (1=small, 2=medium, 3=large)"
    echo -e "  ${GREEN}--worldname${RESET} <name>             World name when using --autocreate"
    echo -e "  ${GREEN}--seed${RESET} <seed>                  World seed when using --autocreate"
    echo
    echo -e "${BOLD}Networking & Security:${RESET}"
    echo -e "  ${GREEN}--ip${RESET} <address>                IP address to bind"
    echo -e "  ${GREEN}--secure${RESET}                      Enable additional cheat protection"
    echo -e "  ${GREEN}--noupnp${RESET}                      Disable UPnP"
    echo -e "  ${GREEN}--banlist${RESET} <file>              Path to banlist file"
    echo
    echo -e "${BOLD}Steam Integration:${RESET}"
    echo -e "  ${GREEN}--steam${RESET}                       Enable Steam support"
    echo -e "  ${GREEN}--lobby${RESET} <friends|private>     Steam lobby visibility"
    echo
    echo -e "${BOLD}Advanced:${RESET}"
    echo -e "  ${GREEN}--forcepriority${RESET} <priority>     Set process priority"
    echo -e "  ${GREEN}--disableannouncementbox${RESET}       Disable announcement box messages"
    echo -e "  ${GREEN}--announcementboxrange${RESET} <num>   Announcement range in pixels (-1 = serverwide)"
    echo
    echo -e "${BOLD}Other:${RESET}"
    echo -e "  ${GREEN}-h${RESET}, ${GREEN}--help${RESET}                Show this help message"
    echo
    echo -e "${BOLD}Notes:${RESET}"
    echo -e "  • All options are passed directly to ${CYAN}TerrariaServer${RESET}"
    echo -e "  • If ${CYAN}--config${RESET} is provided, it overrides all other options"
    echo -e "  • Servers are launched inside a ${CYAN}tmux${RESET} session"
    echo -e "  • The server runs via ${CYAN}mono${RESET} (Raspberry Pi compatible)"
    echo
    echo -e "${BOLD}Examples:${RESET}"
    echo -e "  ${CYAN}TManager launch${RESET} -s terraria --config vanilla.cfg"
    echo -e "  ${CYAN}TManager launch${RESET} -s terraria --world worlds/MyWorld.wld --port 7777"
    echo -e "  ${CYAN}TManager launch${RESET} -s terraria --autocreate 2 --worldname MyWorld --seed abc123"
}

## Parse out the command line arguments.
function parse_args {
    local PARSED

    # If no args are given
    [[ $# -eq 0 ]] && {
        print_usage
        exit 0
    }

    # Handle the help command
    for arg in "$@"; do
	case "$arg" in
            -h|--help)
		print_usage
		exit 0
		;;
	esac
    done

    PARSED=$(getopt -o s:c:p:w:m:h \
		    --long \
		    session:,config:,port:,world:,players:, \
		    maxplayers:,pass:,password:,motd:,autocreate:, \
		    banlist:,worldname:,secure,noupnp,steam,\
		    lobby:,ip:,forcepriority:,disableannouncementbox,announcementboxrange:,\
		    seed:,help \
		    -- "$@")

    # Make sure all arguments are valid.
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}[TManager Launch]:${RESET} Invalid arguments"
        print_usage
        exit 1
    fi

    eval set -- "$PARSED"

    while true; do
        case "$1" in
            -s|--session)
                SESSION="$2"
                shift 2
                ;;
            -c|--config)
                CONFIG="$2"
                shift 2
                ;;
            --port)
                SERVER_ARGS+=("-port" "$2")
                shift 2
                ;;
            --players|--maxplayers)
                SERVER_ARGS+=("-maxplayers" "$2")
                shift 2
                ;;
            --pass|--password)
                SERVER_ARGS+=("-password" "$2")
                shift 2
                ;;
            --motd)
                SERVER_ARGS+=("-motd" "$2")
                shift 2
                ;;
            --world)
                SERVER_ARGS+=("-world" "$2")
                shift 2
                ;;
            --autocreate)
                SERVER_ARGS+=("-autocreate" "$2")
                shift 2
                ;;
            --banlist)
                SERVER_ARGS+=("-banlist" "$2")
                shift 2
                ;;
            --worldname)
                SERVER_ARGS+=("-worldname" "$2")
                shift 2
                ;;
            --secure)
                SERVER_ARGS+=("-secure")
                shift
                ;;
            --noupnp)
                SERVER_ARGS+=("-noupnp")
                shift
                ;;
            --steam)
                SERVER_ARGS+=("-steam")
                shift
                ;;
            --lobby)
                SERVER_ARGS+=("-lobby" "$2")
                shift 2
                ;;
            --ip)
                SERVER_ARGS+=("-ip" "$2")
                shift 2
                ;;
            --forcepriority)
                SERVER_ARGS+=("-forcepriority" "$2")
                shift 2
                ;;
            --disableannouncementbox)
                SERVER_ARGS+=("-disableannouncementbox")
                shift
                ;;
            --announcementboxrange)
                SERVER_ARGS+=("-announcementboxrange" "$2")
                shift 2
                ;;
            --seed)
                SERVER_ARGS+=("-seed" "$2")
                shift 2
                ;;
            --)
                shift
                break
                ;;
            *)
                echo -e "${RED}[TManager Launch]:${RESET} Unknown option '$1'"
                print_usage
                exit 1
                ;;
        esac
    done
}


## Used to make sure that the session is not allready in use in tmux.
function validate_session {
    if tmux has-session -t "$SESSION" 2>/dev/null; then
        echo -e "${RED}[TManager Launch]:${RESET} Session '$SESSION' already exists"
        exit 1
    fi
}


function build_server_args {
    FINAL_ARGS=()
    
    # 1. Config first (lowest precedence)
    if [[ -n "$CONFIG" ]]; then
        FINAL_ARGS+=("-config" "$CONFIG")
    fi
    
    # 2. CLI options override config
    if [[ ${#SERVER_ARGS[@]} -gt 0 ]]; then
        FINAL_ARGS+=("${SERVER_ARGS[@]}")
    fi
}


function launch {
    validate_session
    build_server_args

    echo -e "${GREEN}[TManager Launch]:${RESET} Starting server in tmux session '${SESSION}'"
    echo -e "${CYAN}[Command]:${RESET} mono \"$TSERVER\" ${FINAL_ARGS[*]}"
    
    tmux new-session -d -s "$SESSION" \
         "mono \"$TSERVER\" ${FINAL_ARGS[*]}"
}


#endregion Functions

parse_args "$@"

if [[ -z "$SESSION" ]]; then
    echo -e "${RED}[TManager Launch]:${RESET} --session is required"
    echo -e "See ${YELLOW}--help${RESET} for more info"
    exit 1
fi

launch


