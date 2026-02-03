#! /usr/bin/env bash

source $HOME/.config/terraria-manager.cfg

## TServer-Fetch:
## Written By: Jachin Minyard
##
## Used to fetch and store the terraria server files from a steam installation.
## Used in keeping dedicated terraria servers up to date with releases before,
## the official server files is released to the wiki. This is written for a raspi and as
## such not all the files are needed. 
##
## Files will be fetched from one of a few different places based on where terraria
## is installed some of these location could be:
## $HOME/snap/steam/common/.local/share/Steam/steamapps/common/Terraria/
## $HOME/.local/share/Steam/steamapps/common/Terraria/
## $HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/common/Terraria/
##
## If none of these places have the files we need the program exits with an error code of 1

## INSTALL LOCATIONS ##
STEAM_INSTALL="$HOME/.local/share/Steam/steamapps/common/Terraria/"
SNAP_INSTALL="$HOME/snap/steam/common/.local/share/Steam/steamapps/common/Terraria/"
FLAT_INSTALL="$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/common/Terraria/"

## FILES TO COPY ##
CHANGE_LOG="changelog.txt"
FNA_DLL="FNA.dll*"
SERVER="TerrariaServer*"
WINDOWS_DLL="WindowsBase.dll"
MACHINE_CONF="monomachineconfig"
LIB64="lib64/"

## Where to place a copy of the needed files.
TEMP_SERVER_DIR="$HOME/.tserver-temp"


## Takes in a prefix path and copies the files from that path
function cp_files {
    if [[ -z "$1" ]]; then
        echo "[TManager-fetch ERROR]: No source path provided to cp_files"
        exit 1
    fi

    if [[ "$1" != "$STEAM_INSTALL" && "$1" != "$SNAP_INSTALL" && "$1" != "$FLAT_INSTALL" ]]; then
        echo "[TManager-fetch ERROR]: Invalid install path: $1"
        exit 1
    fi
    
    cp "$1/$CHANGE_LOG"        "$TEMP_SERVER_DIR"
    cp "$1/"$FNA_DLL                "$TEMP_SERVER_DIR"
    cp "$1/"$SERVER                "$TEMP_SERVER_DIR"
    cp -r "$1/$LIB64"                "$TEMP_SERVER_DIR"
    cp "$1/$WINDOWS_DLL"        "$TEMP_SERVER_DIR"
    cp "$1/$MACHINE_CONF"        "$TEMP_SERVER_DIR"
}


function main {
    # make sure the required ENVIRONMENT variables are set.
    if [[ -z "$TSERVER_DIR" ]]; then
        echo "[TManager-fetch ERROR]: TSERVER_DIR is not set"
        exit 1
    fi
    
    if [[ ! -d "$TSERVER_DIR" ]]; then
        echo "[TManager-fetch LOG]: TSERVER_DIR does not exist: $TSERVER_DIR, creating directory..."
    mkdir -p "$TEMP_SERVER_DIR"
    fi

    
    # copy the required files.
    if [[ -d "$STEAM_INSTALL/" ]]; then
    echo "[TManager-fetch LOG]: Install determined as STEAM"
    cp_files $STEAM_INSTALL
    elif [[ -d "$SNAP_INSTALL/" ]]; then
    echo "[TManager-fetch LOG]: Install determined as SNAP"
    cp_files $SNAP_INSTALL
    elif [[ -d "$FLAT_INSTALL/" ]]; then
    echo "[TManager-fetch LOG]: Install determined as FLATPAK"
    cp_files $FLAT_INSTALL
    else
    echo "[TManager-fetch ERROR]: No install path could be determined, exiting..."
    exit 1
fi
}



main
