#!/bin/bash

### CONFIG ###
# TASKS_DIR	- dir where fetched tasks will be located
config_file="$HOME/.dtom.conf"

BIN_DIR=$PWD/${0%/*};
source "$BIN_DIR/driver.sh.functions"

if [ -f "$config_file" ]; then
	read_config "$config_file"

	validate_vars "$config_file"

	(cd "$TASKS_DIR" && fetch_tasks)

#	[ (ls -l | awk '!/^d/{i++;} END{print i}') -gt 0 ]
	[ $(ls -l | grep -v '^d' | wc -l) -gt 0 ]
else
	echo $config_file does not exist
fi

#fetch_tasks "$TASKS_DIR"
