#!/bin/bash

function run_task(){
	local task_id=$1
	touch $task_id.$$
	source $task_id
	rm $task_id.$$
}

function start_tasks(){
	# lockfile name format: task_id.pid
	lock_files=$(ls -1 | grep -i '[0-9a-f]\{32\}\.[0-9]*$')
	lock_files_cnt=$(ls -1 | grep -ci '[0-9a-f]\{32\}\.[0-9]*$')

	#if exist only one lockfile
	case $lock_files_cnt in
		1)	# task is already running, or task previously stoped
			local task_id=$(echo $lock_files | cut -f1 -d.)
			local pid=$(echo $lock_files | cut -f2 -d.)

			# if task is not running (stoped previously)
			if [[ -z $(ps -e | grep "$pid.*$task_id") ]]; then
				rm $lock_files
				run_task $task_id
			fi
			;;
		0)
			local task_id=$(ls -1rt | line)			#oldest task
			[ -n task_id ] && run_task $task_id
			;;
		*)
			echo oth
			;;
	esac
}

