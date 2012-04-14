#!/bin/bash
#
# MaSh - eMail Shell
# Copyright (C) 2012, Eldar Zakirov <unixod@gmail.com>
#
# This file is part of MaSh.
#
# MaSh is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# MaSh is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
#
#  task_loader.sh - tasks loading, executing, killng, monitoring functions


#private function
function run_task(){
	local task_id=$1
	local completed_tasks_dir=$2
	local aborted_tasks_dir=$3

	touch $task_id.$$
	./$task_id
	local ret=$?
	rm $task_id.$$

	local status_dir=$completed_tasks_dir
	[ $ret -ne 0 ] &&
		status_dir=$aborted_tasks_dir
	
	mv $task_id "$status_dir"
}

function start_tasks(){
# usage: start_tasks $completed_tasks_dir
#
# Execute task-file. When task will be completed, it will be moved to $completed_tasks_dir

	local completed_tasks_dir=$1
	local aborted_tasks_dir=$2
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
		run_task $task_id $completed_tasks_dir $aborted_tasks_dir
}

