#!/usr/bin/env bash

## Simple ASCII escape commands to modify text
# Text styles
RESET='\e[0m'
BOLD='\e[1m'
ITALIC='\e[3m'
UNDERLINE='\e[4m'

# Foreground colors (bright)
BLACK='\e[90m'
RED='\e[91m'
GREEN='\e[92m'
YELLOW='\e[93m'
BLUE='\e[94m'
MAGENTA='\e[95m'
CYAN='\e[96m'
WHITE='\e[97m'


## Prompt the user to continue.
function y_n_prompt {
    local prompt="$1"
    local res

    while true; do
	echo -ne "$prompt"
        read -r res
        case "${res,,}" in
            y|yes) return 0 ;;
            n|no) return 1 ;;
            *) echo "Please answer y or n." ;;
        esac
    done
}


## Used to add a path to the shell config and alert the user upon doing so.
function add_to_path {
    if [[ $# -ne 2 ]]; then
        echo "[TManager ERROR]: add_to_path expects 2 arguments:"
        echo "  add_to_path <shell_file> <path>"
        return 1
    fi
    
    local shell_file="$1"
    local path="$2"

    touch "$shell_file"

    # Already active in current shell
    [[ ":$PATH:" == *":$path:"* ]] && return

    # Already in shell config
    grep -qxF "export PATH=\"$path:\$PATH\"" "$shell_file" && return

    {
        echo
        echo "# Added by Terraria Manager installer"
        echo "export PATH=\"$path:\$PATH\""
    } >> "$shell_file"

    echo "${YELLOW}${BOLD}[TManager Install]:${RESET} ${YELLOW}Added $path to PATH in $shell_file${RESET}"
}


## Creates a formated help page title.
function help_title {
    local title="$1"
    local subtitle="$2"

    echo -e "${TITLE_COLOR}${UNDERLINE}${BOLD}${title}${RESET} ${HIGHLIGHT_COLOR}${UNDERLINE}— ${subtitle}${RESET}"
    echo
}


## Creates a help section title.
function help_section {
    local name="$1"
    echo -e "${TITLE_COLOR}${BOLD}${UNDERLINE}${name}:${RESET}"
}


## Creates a formated option in the help page
function help_option {
    local flags="$1"
    local arg="$2"
    local desc="$3"

    # If no arg column, keep spacing aligned
    if [[ -z "$arg" ]]; then
        printf "  %b%-*s%b  %b%-*s%b  %s\n" \
            "$OPT_COLOR" "$HELP_FLAGS_WIDTH" "$flags" "$RESET" \
            "$HIGHLIGHT_COLOR" "$HELP_ARG_WIDTH" "" "$RESET" \
            "$desc"
    else
        printf "  %b%-*s%b  %b%-*s%b  %s\n" \
            "$OPT_COLOR" "$HELP_FLAGS_WIDTH" "$flags" "$RESET" \
            "$HIGHLIGHT_COLOR" "$HELP_ARG_WIDTH" "$arg" "$RESET" \
            "$desc"
    fi
}


## Creates a formated note in the help page.
function help_note {
    echo -e "  ${HIGHLIGHT_COLOR}• $*${RESET}"
}
