#!/usr/bin/env bash

## New
## Writen By: Jachin Minyard
## Simple Placeholder
##
## The Idea is to interactivly prompt the user and write the
## choices to a server config file that we can run with TManager launch -c config.cfg


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/setup.sh"
source "$SCRIPT_DIR/utils/common.sh"
source "$TMANAGER_CONFIG/terraria-manager.cfg"


mono --server --gc=sgen -O=all ./"$TERRARIA_SERVER_DIR/$TERRARIA_SERVER"
