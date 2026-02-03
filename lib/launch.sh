#!/usr/bin/env bash

## Launch:
## Written By Jachin Minyard
## Used to launch instances of Terraria Server.
##
## This ones pretty simple it is just a wrapper around tmux mono and Terraria Server
## simply put its arguments and options are the same as TerrariaServer and will be passed
## accordling. A Session name must be provided so that tmux can give each session running a
## a server a name for finding it quickly later. The given session name has ts appended to it
## however when asked for the session name only give the name with out '-ts'


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/setup.sh"
source "$SCRIPT_DIR/utils/common.sh"
source "$TMANAGER_CONFIG/terraria-manager.cfg"


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

SESSION_TS=""

#endregion Variables


#region Functions
## Prints out a simple help menu for this command.
function print_usage {
    help_title "TManager launch" "Launch a Terraria server instance"
    help_section "Usage"
    echo -e "  ${CMD_COLOR}TManager launch${RESET} ${OPT_COLOR}--session${RESET} <name> [TerrariaServer options]"
    echo
    help_section "Required"
    help_option "-s, --session" "<name>" "Name of the tmux session to run the server in"
    echo
    help_section "Common Options"
    help_option "-c, --config" "<file>" "Use a Terraria server config file"
    help_option "--port" "<number>" "Server port"
    help_option "--world" "<path>" "Path to world file"
    help_option "--players, --maxplayers" "<number>" "Maximum number of players"
    help_option "--password" "<password>" "Server password"
    help_option "--motd" "<text>" "Message of the day"
    echo
    help_section "World Creation"
    help_option "--autocreate" "<1|2|3>" "Create world if missing (1=small, 2=medium, 3=large)"
    help_option "--worldname" "<name>" "World name when using --autocreate"
    help_option "--seed" "<seed>" "World seed when using --autocreate"
    echo
    help_section "Networking & Security"
    help_option "--ip" "<address>" "IP address to bind"
    help_option "--secure" "" "Enable additional cheat protection"
    help_option "--noupnp" "" "Disable UPnP"
    help_option "--banlist" "<file>" "Path to banlist file"
    echo
    help_section "Steam Integration"
    help_option "--steam" "" "Enable Steam support"
    help_option "--lobby" "<friends|private>" "Steam lobby visibility"
    echo
    help_section "Advanced"
    help_option "--forcepriority" "<priority>" "Set process priority"
    help_option "--disableannouncementbox" "" "Disable announcement box messages"
    help_option "--announcementboxrange" "<num>" "Announcement range (-1 = serverwide)"
    echo
    help_section "Other"
    help_option "-h, --help" "" "Show this help message"
    echo
    help_section "Notes"
    help_note "All options are passed directly to TerrariaServer"
    help_note "Command-line options override config values"
    help_note "Servers are launched inside tmux"
    help_note "The server runs via mono (Raspberry Pi compatible)"
    echo
    help_section "Examples"
    echo -e "  ${CMD_COLOR}TManager launch ${RESET} ${YELLOW}-s${RESET} terraria ${YELLOW}--config${RESET} vanilla.cfg"
    echo -e "  ${CMD_COLOR}TManager launch ${RESET} ${YELLOW}-s${RESET} terraria ${YELLOW}--world${RESET} worlds/MyWorld.wld ${YELLOW}--port${RESET} 7777"
    echo -e "  ${CMD_COLOR}TManager launch ${RESET} ${YELLOW}-s${RESET} terraria ${YELLOW}--autocreate${RESET} 2 ${YELLOW}--worldname${RESET} MyWorld ${YELLOW}--seed${RESET} abc123"
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
    if tmux has-session -t "$SESSION_TS" 2>/dev/null; then
        echo -e "${RED}[TManager Launch]:${RESET} Session '$SESSION_TS' already exists"
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

    echo -e "${GREEN}[TManager Launch]:${RESET} Starting server in tmux session '${SESSION_TS}'"
    echo -e "${CYAN}[Command]:${RESET} mono \"$TERRARIA_SERVER_DIR/$TERRARIA_SERVER\" ${FINAL_ARGS[*]}"
    
    tmux new-session -d -s "$SESSION_TS" \
        "mono --server --gc=sgen -O=all \"$TERRARIA_SERVER_DIR/$TERRARIA_SERVER\" ${FINAL_ARGS[*]}"
}


#endregion Functions

parse_args "$@"

if [[ -z "$SESSION" ]]; then
    echo -e "${RED}[TManager Launch]:${RESET} --session is required"
    echo -e "See ${YELLOW}--help${RESET} for more info"
    exit 1
fi

SESSION_TS="${SESSION}-ts"
launch


