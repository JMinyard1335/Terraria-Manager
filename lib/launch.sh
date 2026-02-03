#!/usr/bin/env bash

source "$HOME/.config/terraria-manager/terraria-manager.cfg"
source "$HOME/.config/terraria-manager/terraria-manager.env"
source "$TMANAGER_LIB/common.sh"

## Launch:
## Written By Jachin Minyard
## Used to launch instances of Terraria Server.
##
## Can either launch instances by giving it all the parameters
## or by giving it a path to a config. If a config is provided at all even with
## the other parameters it will be used and the other parameters will be ignored.
## Server session are launched in tmux with the provided session name.


#region Variables
SERVER_ARG=()
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
function print_usage {
    echo -e "${BOLD}TManager launch${RESET} — Launch Terraria server instances"
    echo

    echo -e "${BOLD}Usage:${RESET}"
    echo -e "  ${CYAN}TManager launch${RESET} [options]"
    echo

    echo -e "${BOLD}Options:${RESET}"
    echo -e "  ${GREEN}-s${RESET}, ${GREEN}--session${RESET} <name>       Name of the tmux session to create"
    echo -e "  ${GREEN}-c${RESET}, ${GREEN}--config${RESET} <file>        Launch using a server config file"
    echo -e "  ${GREEN}-p${RESET}, ${GREEN}--port${RESET} <port>         Port for the Terraria server"
    echo -e "  ${GREEN}-w${RESET}, ${GREEN}--world${RESET} <path>        Path to the world file"
    echo -e "  ${GREEN}-m${RESET}, ${GREEN}--max-players${RESET} <num>   Maximum number of players"
    echo -e "  ${GREEN}-h${RESET}, ${GREEN}--help${RESET}                Show this help message"
    echo

    echo -e "${BOLD}Notes:${RESET}"
    echo -e "  • If ${CYAN}--config${RESET} is provided, all other options are ignored"
    echo -e "  • Servers are launched inside a ${CYAN}tmux${RESET} session"
    echo -e "  • The server is started using ${CYAN}mono${RESET} (Raspberry Pi compatible)"
    echo

    echo -e "${BOLD}Examples:${RESET}"
    echo -e "  ${CYAN}TManager launch${RESET} --config vanilla.cfg"
    echo -e "  ${CYAN}TManager launch${RESET} --session terraria --world worlds/MyWorld.wld"
    echo -e "  ${CYAN}TManager launch${RESET} -s terraria -p 7777 -m 8"
}

## Parse out the command line arguments.
function parse_args {
    :
}
## Used to make sure that the session is not allready in use.
function validate_session {
    :
}
function launch_config {
    :
}
function launch_custom {
    :
}

#endregion Functions


print_usage
