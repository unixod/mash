#!/usr/bin/awk -f

# Task File Generator - parses stdinput and generate task-file
# First line must be task name

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
	if(task_name && batch)
		printf("#%s\n%s\n", task_name, batch) > task_file
}



### Functions ###

function addNewBlockSeparator(blck_name){
	blocks = (blocks (blocks ? "|" : "") "\\[" blck_name "\\]")
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

