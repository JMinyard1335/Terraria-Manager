#!/usr/bin/env bash

## Install
## Written By: Jachin Minyard
## Subcommand of TManager, Installs the Terraria Server.
##
## Used to install the latest version of the Terraria Server.
## This does not make a backup of the current server do that with TManager backup --server
## Or to do a full update run TManager update
## Can remove probalmatic files for raspi during install.


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/setup.sh"
source "$SCRIPT_DIR/utils/common.sh"
source "$TMANAGER_CONFIG/terraria-manager.cfg"


LATEST="1453" # Latest version of the server.
CUSTOM_VERSION=""
PI=false
FORCE=false


function print_usage {
    help_title "TManager install" "Install the Terraria dedicated server"

    help_section "Usage"
    echo "  ${CMD_COLOR}TManager install${RESET} [options]"
    echo
    
    help_section "Options"
    help_option "-v, --version" "<build>" "Install a specific server build (default: ${LATEST})"
    help_option "-p, --pi"      ""        "Removes files that often cause crashes on raspi's"
    help_option "-f, --force"   ""        "Skip confirmation prompt and install immediately"
    help_option "-h, --help"    ""        "Show this help message"

    help_section "Notes"
    help_note "By default, installs the latest known server build (${LATEST})"
    help_note "This does NOT back up an existing server"
    help_note "Use ${CMD_COLOR}TManager backup --server${RESET} before reinstalling"
    echo

    help_section "Examples"
    echo -e "  ${CMD_COLOR}TManager install${RESET}"
    echo -e "  ${CMD_COLOR}TManager install --version 1449${RESET}"
}


function parse_args {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -v|--version)
                if [[ -z "$2" ]]; then
                    echo -e "${ERROR_COLOR}[TManager Install]:${RESET} --version requires an argument"
                    exit 1
                fi
                CUSTOM_VERSION="$2"
                shift 2
                ;;
            -p|--pi)
                PI=true
                shift
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            -h|--help)
                print_usage
                exit 0
                ;;
            *)
                echo -e "${ERROR_COLOR}[TManager Install]:${RESET} Unknown option '$1'"
                echo -e "See ${CMD_COLOR}--help${RESET} for usage"
                exit 1
                ;;
        esac
    done

    if [[ -n "$CUSTOM_VERSION" ]]; then
        LATEST="$CUSTOM_VERSION"
    fi
}


function start_download {
    if [[ "$FORCE" == true ]]; then
        echo -e "${YELLOW}[TManager Install]:${RESET} --force specified, skipping confirmation"
        return 0
    fi

    echo -e "${RED}${UNDERLINE}${BOLD}!!!STOP!!!${RESET}"
    echo "This will install the Terraria dedicated server from www.https://terraria.wiki.gg/wiki/Server"
    echo "Doing so does not create a backup of the current server if there is one."
    echo "Please run:"
    echo -e "\t'${RED}TManager backup --server${RESET}' or '${RED}TManager update${RESET}'"
    echo "to create a backup before upgrading"
    echo
    echo -e "${YELLOW}• If installing on a Raspi install with --pi flag${RESET}"
    echo

    if ! y_n_prompt "would you like to continue? (Y/n): "; then
        echo "Installation cancelled."
        exit 0
    fi
}


function download_latest {
    local build="$LATEST"
    local url="https://terraria.org/api/download/pc-dedicated-server/terraria-server-${build}.zip"
    local zip_name="terraria-server-${build}.zip"
    local zip_path="$TMANAGER_DOWNLOADS/$zip_name"

    mkdir -p "$TMANAGER_DOWNLOADS"

    echo -e "${GREEN}[TManager Install]:${RESET} Downloading Terraria server build ${build}"
    echo -e "${HIGHLIGHT_COLOR}[URL]: $url${RESET}"
    echo
    
    if ! wget -O "$zip_path" "$url"; then
        echo -e "${ERROR_COLOR}[TManager Install]:${RESET} Download failed"
        exit 1
    fi

    echo -e "${GREEN}[TManager Install]:${RESET} Download complete → $zip_path"
}


function apply_download {
    local build="$LATEST"
    local zip="$TMANAGER_DOWNLOADS/terraria-server-${build}.zip"
    local extract_dir="$TMANAGER_EXTRACT/terraria-server-${build}"

    if [[ ! -f "$zip" ]]; then
        echo -e "${ERROR_COLOR}[TManager Install]:${RESET} Missing download: $zip"
        exit 1
    fi

    mkdir -p "$extract_dir"
    mkdir -p "$TERRARIA_SERVER_DIR"

    echo -e "${GREEN}[TManager Install]:${RESET} Extracting server files"

    unzip -o "$zip" -d "$extract_dir"

    # Copy only Linux server payload
    cp -r "$extract_dir/${build}"/Linux/* "$TERRARIA_SERVER_DIR"
    cd "$TERRARIA_SERVER_DIR"
    if [[ "$PI" == true ]]; then
	echo -e "${YELLOW}[TManager Install]:${RESET} Applying Raspberry Pi compatibility cleanup"
	echo -e "${YELLOW}[TManager Install]:${RESET} This will remove files that end up conflicting"
	
	rm -f System*
	rm -f Mono*
	rm -f monoconfig
	rm -f mscorlib.dll
    fi

    chmod +x TerrariaServer*
    echo -e "${GREEN}[TManager Install]:${RESET} Server installed to $TERRARIA_SERVER_DIR"
}


parse_args "$@"
start_download
download_latest
apply_download
