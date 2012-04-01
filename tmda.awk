#!/usr/bin/awk -f

# Task-mail Delivery Agent

BEGIN {
	FS = ": "
	head = 1;
	multipart_boundary = 0;
	
	### CONFIGURATION ###
	subject_pattern = "task: (.+)";
}


#Body
!head && (!multipart_boundary || ($0 !~ multipart_boundary)){
	if($0) print
}

#Body separator
(head == 1) && $0 == ""{
	head = 0;
}

#Multipart separator (optional)
multipart_boundary && ($0 ~ multipart_boundary){
	if(!--head) exit
}

#Headers
/[^ ]+: [^ ]+/ && head{
	if($1 == "Subject"){
		#extracting subject value
		sbj = $0;
		sub(/[^:]+: /, "", sbj);

		if(task_id = getTaskName(sbj)) print task_id;
		else exit;
	} else if($1 == "Content-Type" &&
		  $2 == "multipart/alternative;"){
		if(getline > 0){
			if(match($0, /boundary="(.+)"/, arr) > 0){
				multipart_boundary = (arr[1] "$");
				head = 2;
			}
		} else {
			msg = "unexpected EOF or error";
			msg = (msg ": " ERRNO);
			print msg > "/dev/stderr"
			exit
		}
	}
}


### Functions ###

function getTaskName(sbj){
	return match(sbj, subject_pattern, arr) ? arr[1] : "";
}

