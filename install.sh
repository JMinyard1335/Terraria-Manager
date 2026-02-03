#!/usr/bin/env bash

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/configs/terraria-manager.cfg"
source "$SCRIPT_DIR/lib/utils/common.sh"
source "$SCRIPT_DIR/lib/utils/setup.sh"

## Install Script:
## Written By: Jachin Minyard
## Simple install script
##
## This is not fancy it simply moves the files into the right place and gives them the right premission.
## I would say the scripts that run are well documented and readable. it is UP TO THE USER to look over
## the code they run on there computer. This is by no means fully secure software and is meant to
## be used for simple hobby project to host terraria servers.


## used to prompt the user if they want to begin the installation process.
function start_install {
    echo -e "${UNDERLINE}${BOLD}\tWelcome to the Terraria Manager installer.${RESET}"
    echo -e "This project is not affiliated with, sponsored by, or worked on by Re-Logic."
    echo "Its purpose is to streamline the management of multiple dedicated Terraria servers."
    echo
    if ! y_n_prompt "Would you like to continue the install? (y/n): "; then
	echo "Installation cancelled."
	exit 0
    fi
}


## Copy over the default config if they do not allready have one.
function install_config {
    # copy the configs to the config destination
    echo "[TManager Install]: Setting up the configuration files..."
    mkdir -p "$TMANAGER_CONFIG"
    shopt -s nullglob
    cp "$SCRIPT_DIR/configs/"* "$TMANAGER_CONFIG"
    shopt -u nullglob
}



## Copy all the files to the required destination.
function install_lib {
    # copy the library to the library destination 
    echo "[TManager Install]: Setting up the library files..."
    mkdir -p "$TMANAGER_LIB"
    shopt -s nullglob
    cp -r "$SCRIPT_DIR/lib/"* "$TMANAGER_LIB"
    shopt -u nullglob
    chmod +x "$TMANAGER_LIB"/*
}


## Install the commands to the users local bin
function install_cmds {
    # copy the library to the library destination 
    echo "[TManager Install]: Setting up the commands..."
    mkdir -p "$TMANAGER_CMDS"
    shopt -s nullglob
    cp "$SCRIPT_DIR/commands/"* "$TMANAGER_CMDS"
    shopt -u nullglob
    chmod +x "$TMANAGER_CMDS"/*
}


## Makes sure the local bin is on the users path.
function set_up_path {
    SHELL_NAME="$(basename "$SHELL")"

    case "$SHELL_NAME" in
        bash)
            add_to_path "$HOME/.bashrc" "$TMANAGER_CMDS"
            ;;
        zsh)
            add_to_path "$HOME/.zshrc" "$TMANAGER_CMDS"
            ;;
        *)
            echo "[TManager Install]: Unsupported shell ($SHELL_NAME)."
            echo "Please add $TMANAGER_CMDS to your PATH manually."
            ;;
    esac
}


function install {
    start_install
    install_config
    install_lib
    install_cmds
    set_up_path

    echo
    echo "[TManager Install]: Installation complete."
    echo "Restart your shell or run:"
    echo "  source ~/.bashrc"
}


install
