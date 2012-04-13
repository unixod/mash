#!/bin/bash

function run_task(){
	local task_id=$1
	local complete_tasks_dir=$2

	touch $task_id.$$
	source $task_id
	rm $task_id.$$
	mv $task_id $complete_tasks_dir
}

function start_tasks(){
# usage: start_tasks $complete_tasks_dir
#
# Execute task-file. When task will be completed, it will be moved to $complete_tasks_dir

	local complete_tasks_dir=$1
	local TASK_ID_PTRN='[0-9a-f]{32}'

	# lockfile name format: task_id.pid
	local lock_file=$(ls -1rt | grep -iE ${TASK_ID_PTRN}'\.[0-9]+$' | line)
	local task_id

	if [[ -n $lock_file ]]; then
		# task is already running, or previously stoped
		task_id=$(echo $lock_file | cut -f1 -d.)
		local pid=$(echo $lock_file | cut -f2 -d.)

		# if task is not running (stoped previously)
		if [[ -z $(ps -e | grep "$pid.*$task_id") ]]; then
			#remove old lockfiles
			find . -regextype posix-extended -regex '^.*/'${TASK_ID_PTRN}'\.[0-9]+$' -exec rm {} \;
		fi	
	fi

	[[ ! -f $task_id ]] &&
		task_id=$(ls -1rt --file-type | grep -iE '^'${TASK_ID_PTRN}'$' | line)			# oldest task

	[[ -f $task_id ]] &&
		run_task $task_id $complete_tasks_dir
}

