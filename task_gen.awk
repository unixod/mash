#!/usr/bin/awk -f
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
#  task_gen.awk - Task File Generator, parses stdin and generate task-file with
#                 name - md5 sum of task name.
#                 First line (in stdin) must be task name.
#
#  stdin data format:
#                 1-st line:		task name (must be matched to
#                                                  $subject_pattern, see code)
#                 n-th line:		[SECTION_NAME]
#                 n+1 and others lines:	section data
#
#  supported sections:
#                 batch - shell commands
#
#  stdin data example:
#                 task: Sample task
#                 [batch]
#                 echo "Hello World!!!" > $HOME/test


BEGIN{
	blocks = "";
	current_block = "";
	addNewBlockSeparator("batch");

	task_name = "";
	task_file = "";
	batch = "";
	### CONFIGURATION ###
	subject_pattern = "task: (.+)";
}

# Task name
FNR == 1{
	task_name = getTaskName($0);
	task_file = md5sum(task_name);
}

# Task body
task_name && (current_block == "[batch]"){
	batch = (batch "\n" $0);
}

# Block separators
$0 ~ blocks {current_block = $0}

END {
	if(task_name && batch){
		printf("%s\n#%s\n", batch, task_name) > task_file;
		printf("chmod u+x %s\n", task_file) | "sh";
		close("sh");
	}
}



### Functions ###

function addNewBlockSeparator(blck_name){
	blocks = (blocks (blocks ? "|" : "") "\\[" blck_name "\\]");
}

function getTaskName(sbj){
	return match(sbj, subject_pattern, arr) ? arr[1] : "";
}

function md5sum(val){
	command = ("echo \"" val "\" | md5sum | sed 's/\\s.*//'");
	command | getline ret;
	close(command);
	return ret;
}

