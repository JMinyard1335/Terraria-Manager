# Terraria Manager
This is a hoby project and something I started to help streamline when I needed to work on any of the servers.  It is a collection of tools to help manage 
and automate running multiple terraria server instances on a single machine. 

## Manager Config
The manager needs to know a few different things about how your Terraria server is set up. To keep from forcing everyone to use the same layout that I do, 
I simply created a config file that holds some default values (my layout) that can be changed by the user. Make sure that all these values are set in the configuration file.
the file should be located at 

``` bash
$HOME/.config/terraria-manager.cfg
```

### TERRARIA_MGR_DIR

## Server Config

## API
These are the basic commands that can be given to the manager.
``` shell
TManager new
TManager launch	<config>		# Launch a server based on the config file.
TManager stop	<config>		# Stop the server running the given config.
TManager view	<config>		# View the server running the given config.
TManager update					# Update the server to the newest version.
TManager backup [options]		# Creates backups of the worlds and config files.
```

