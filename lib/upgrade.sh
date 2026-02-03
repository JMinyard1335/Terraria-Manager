#!/usr/bin/env bash

## Upgrade
## Written by: Jachin Minyard
## Used to upgrade the TManager tool chain.
##
## This command upgrades the current installation of TManager with
## The newest version pulled from github.


#!/usr/bin/env bash

## Upgrade
## Written by: Jachin Minyard
## Used to upgrade the TManager tool chain.
##
## This command upgrades the current installation of TManager with
## the newest version pulled from GitHub.


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/setup.sh"
source "$SCRIPT_DIR/utils/common.sh"
source "$TMANAGER_CONFIG/terraria-manager.cfg"


PROJECT_REPO="https://github.com/JMinyard1335/Terraria-Manager/archive/refs/heads/main.zip"

TMANAGER_SOURCE="$TMANAGER_HOME/source"
TMANAGER_SOURCE_ZIP="$TMANAGER_SOURCE/tmanager-latest.zip"
TMANAGER_SOURCE_EXTRACT="$TMANAGER_SOURCE/extracted"


function print_usage {
    help_title "TManager upgrade" "Upgrade the TManager toolchain"

    help_section "Usage"
    echo -e "  ${CMD_COLOR}TManager upgrade${RESET} [options]"
    echo

    help_section "Options"
    help_option "-h, --help" "" "Show this help message"
    echo

    help_section "Notes"
    help_note "Downloads the latest TManager source from GitHub"
    help_note "Runs the install script from the downloaded source"
    help_note "Does NOT remove your Terraria servers or worlds"
    echo

    help_section "Examples"
    echo -e "  ${CMD_COLOR}TManager upgrade${RESET}"
}


function parse_args {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                print_usage
                exit 0
                ;;
            *)
                echo -e "${ERROR_COLOR}[TManager Upgrade]:${RESET} Unknown option '$1'"
                echo -e "See ${CMD_COLOR}--help${RESET} for usage"
                exit 1
                ;;
        esac
    done
}


function download_source {
    echo -e "${GREEN}[TManager Upgrade]:${RESET} Downloading latest source from GitHub"
    echo -e "${HIGHLIGHT_COLOR}[URL]:${RESET} $PROJECT_REPO"

    mkdir -p "$TMANAGER_SOURCE"

    if ! wget -O "$TMANAGER_SOURCE_ZIP" "$PROJECT_REPO"; then
        echo -e "${ERROR_COLOR}[TManager Upgrade]:${RESET} Download failed"
        exit 1
    fi
}


function extract_source {
    echo -e "${GREEN}[TManager Upgrade]:${RESET} Extracting source"

    rm -rf "$TMANAGER_SOURCE_EXTRACT"
    mkdir -p "$TMANAGER_SOURCE_EXTRACT"

    if ! unzip -q "$TMANAGER_SOURCE_ZIP" -d "$TMANAGER_SOURCE_EXTRACT"; then
        echo -e "${ERROR_COLOR}[TManager Upgrade]:${RESET} Failed to extract source"
        exit 1
    fi
}


function run_install {
    local project_dir

    project_dir="$(find "$TMANAGER_SOURCE_EXTRACT" -mindepth 1 -maxdepth 1 -type d | head -n 1)"

    if [[ -z "$project_dir" ]]; then
        echo -e "${ERROR_COLOR}[TManager Upgrade]:${RESET} Could not locate extracted project directory"
        exit 1
    fi

    if [[ ! -x "$project_dir/install.sh" ]]; then
        echo -e "${ERROR_COLOR}[TManager Upgrade]:${RESET} install.sh not found or not executable"
        exit 1
    fi

    echo -e "${GREEN}[TManager Upgrade]:${RESET} Running installer"
    echo -e "  → ${HIGHLIGHT_COLOR}$project_dir/install.sh${RESET}"

    (cd "$project_dir" && ./install.sh)
}


function main {
    parse_args "$@"

    echo -e "${YELLOW}${BOLD}[TManager Upgrade]:${RESET} This will update the TManager toolchain"
    echo

    if ! y_n_prompt "Continue with upgrade? (Y/n): "; then
        echo -e "${YELLOW}[TManager Upgrade]:${RESET} Upgrade cancelled"
        exit 0
    fi

    download_source
    extract_source
    run_install

    echo
    echo -e "${GREEN}${BOLD}[TManager Upgrade]:${RESET} Upgrade complete"
}


main "$@"
