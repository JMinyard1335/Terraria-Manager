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

    echo "[TManager Install]: Added $path to PATH in $shell_file"
}
