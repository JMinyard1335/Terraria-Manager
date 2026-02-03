#!/usr/bin/env bash

## New
## Writen By: Jachin Minyard
## Simple Placeholder
##
## The Idea is to interactivly prompt the user and write the
## choices to a server config file that we can run with TManager launch -c config.cfg

mono --server --gc=sgen -O=all ./"$TERRARIA_SERVER_DIR/$TERRARIA_SERVER"
