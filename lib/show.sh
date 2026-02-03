#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/setup.sh"
source "$SCRIPT_DIR/common.sh"
source "$TMANAGER_CONFIG/terraria-manager.cfg"

LIST_ONLY=false
RUN_CMD=""
SESSION=""
SESSION_TS=""

## List all terraria tmux sessions.
function list_sessions {
    echo -e "${BOLD}Active Terraria Servers:${RESET}"

    local found=false

    while read -r session; do
        [[ -z "$session" ]] && continue
        found=true

        local clean="${session%%-ts*}"
        echo -e "  ${GREEN}$clean${RESET}"
    done < <(
        tmux list-sessions -F '#S' 2>/dev/null | grep -- '-ts'
    )

    if [[ "$found" == false ]]; then
        echo -e "  ${YELLOW}No running Terraria servers found${RESET}"
    fi
}


## Validate session exists and resolve tmux name
function check_for_session {
    local matches

    mapfile -t matches < <(
        tmux list-sessions -F '#S' 2>/dev/null | grep "^${SESSION}-ts"
    )

    if [[ ${#matches[@]} -eq 0 ]]; then
        echo -e "${RED}[TManager View]:${RESET} No running server named '$SESSION'"
        echo
        list_sessions
        exit 1
    fi

    SESSION_TS="${matches[0]}"
}


function print_usage {
    help_title "TManager view" "View or control a running Terraria server"

    help_section "Usage"
    echo -e "  ${CMD_COLOR}TManager view${RESET} [options]"
    echo

    help_section "Options"
    help_option "-s, --session" "<name>" "Server session name (without -ts)"
    help_option "-r, --run" "<command>" "Run a Terraria server command"
    help_option "-l, --list" "" "List all running Terraria servers"
    help_option "-h, --help" "" "Show this help message"
    echo

    help_section "Examples"
    echo -e "  ${CMD_COLOR}TManager view${RESET} --list"
    echo -e "  ${CMD_COLOR}TManager view${RESET} -s Main"
    echo -e "  ${CMD_COLOR}TManager view${RESET} -s Main -r 'say \"Hello\"'"
}


function parse_args {
    [[ $# -eq 0 ]] && {
        print_usage
        exit 1
    }

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -l|--list)
                LIST_ONLY=true
                shift
                ;;
            -s|--session)
                [[ -z "$2" ]] && {
                    echo -e "${RED}[TManager View]:${RESET} --session requires a value"
                    exit 1
                }
                SESSION="$2"
                shift 2
                ;;
            -r|--run)
                [[ -z "$2" ]] && {
                    echo -e "${RED}[TManager View]:${RESET} --run requires a command"
                    exit 1
                }
                RUN_CMD="$2"
                shift 2
                ;;
            -h|--help)
                print_usage
                exit 0
                ;;
            *)
                echo -e "${RED}[TManager View]:${RESET} Unknown option '$1'"
                echo -e "See ${YELLOW}--help${RESET} for usage"
                exit 1
                ;;
        esac
    done

    # --list is standalone
    if [[ "$LIST_ONLY" == true ]]; then
        list_sessions
        exit 0
    fi

    # All other paths require a session
    [[ -z "$SESSION" ]] && {
        echo -e "${RED}[TManager View]:${RESET} --session is required"
        echo -e "See ${YELLOW}--help${RESET} for usage"
        exit 1
    }
}


function view_session {
    check_for_session

    if [[ -n "$RUN_CMD" ]]; then
        echo -e "${GREEN}[TManager View]:${RESET} Sending command to '$SESSION'"
        echo -e "  ${CYAN}> ${RUN_CMD}${RESET}"

        tmux send-keys -t "$SESSION_TS" "$RUN_CMD" Enter
        exit 0
    fi

    echo -e "${GREEN}[TManager View]:${RESET} Attaching to '$SESSION'"
    tmux attach -t "$SESSION_TS"
}


parse_args "$@"
view_session
