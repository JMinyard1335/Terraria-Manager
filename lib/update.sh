#!/usr/bin/env bash

## Update:
## Written By: Jachin Minyard
##
## Used to pull the updated server files off a computer and ssh them over to the server.
## This command is meant to be run on a machine that is not the dedicated server.

SERVER_IP=""
SERVER_HOST=""


function print_usage {
    echo "Usage: $0 --ip <IPv4> --host <username>"
    echo
    echo "Options:"
    echo "  -i, --ip <IPv4>       Server IPv4 address"
    echo "  -h, --host <user>     SSH username on the server"
    echo "      --help            Show this help message"
}


function parse_args {
    PARSED=$(getopt -o i:h: \
        --long ip:,host:,help \
        -- "$@")

    if [[ $? -ne 0 ]]; then
        print_usage
        exit 1
    fi

    eval set -- "$PARSED"

    while true; do
        case "$1" in
            -i|--ip)
                SERVER_IP="$2"
                shift 2
                ;;
            -h|--host)
                SERVER_HOST="$2"
                shift 2
                ;;
            --help)
                print_usage
                exit 0
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "[TManager ERROR]: Unknown option $1"
                exit 1
                ;;
        esac
    done

    # Required argument validation
    if [[ -z "$SERVER_IP" ]]; then
        echo "[TManager ERROR]: --ip is required"
        print_usage
        exit 1
    fi

    if [[ -z "$SERVER_HOST" ]]; then
        echo "[TManager ERROR]: --host is required"
        print_usage
        exit 1
    fi

    validate_ip "$SERVER_IP"
}



## Used to check if the pased in IP is a valid IPV4 address
function validate_ip {
    local ip="$1"

    # Basic pattern check
    if [[ ! "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        echo "[TManager ERROR]: Invalid IPv4 format: $ip"
        exit 1
    fi

    # Range check
    IFS='.' read -r o1 o2 o3 o4 <<< "$ip"
    for octet in $o1 $o2 $o3 $o4; do
        if (( octet < 0 || octet > 255 )); then
            echo "[TManager ERROR]: IPv4 octet out of range: $ip"
            exit 1
        fi
    done
}


## Finds all the necessary files and puts them on the server.
function fetch_update {
    ./fetch.sh # puts needed files in ~/.tserver-temp
    echo "[TManager LOG]: Copying new server files to ${SERVER_HOST}@${SERVER_IP}..."
    scp -r "$HOME/.tserver-temp" "$SERVER_HOST"@"$SERVER_IP":~/
    echo "[TManager LOG]: Update files copied Successfully, removing temp files..."
    rm -r "$HOME/.tserver-temp"
    echo "[TManager LOG]: Tempoary Files cleaned."
}


## Tells the server over ssh to backup the current server.
function backup_server {
    echo "[TManager LOG]: Backing up the current server..."
    ssh $SERVER_HOST@$SERVER_IP "TServer backup -s" ## TODO: Make sure this is implemented.
}


## Tells the  server over ssh to apply the updated files.
function apply_update {
    echo "[TManager LOG]: Applying updates to the terraria server..."
    ssh $SERVER_HOST@$SERVER_IP "TServer apply" ## TODO: Make sure this is implemented.
}


function main {
    parse_args $@
    fetch_update
    backup_server
    apply_update
}


main "$@"
