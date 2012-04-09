#!/usr/bin/awk -f

# Mail Parser - parses mail data to subject and body to stdout

BEGIN {
	FS = ": "
	head = 1;
	multipart_boundary = 0;
	subject = "";
}


# Body
!head && (!multipart_boundary || ($0 !~ multipart_boundary)){
	# non empty lines are output
	# sybject must be set
	if(subject && $0) print
}

# Body separator
(head == 1) && $0 == ""{
	head = 0;
}

# Multipart separator (optional)
multipart_boundary && ($0 ~ multipart_boundary){
	if(!--head) exit
}

# Headers
/[^ ]+: [^ ]+/ && head{
	if($1 == "Subject"){
		# extracting subject value
		subject = $0;
		sub(/[^:]+: /, "", subject);

		print subject;
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

#function getTaskName(sbj){
#	return match(sbj, subject_pattern, arr) ? arr[1] : "";
#}

#function md5_sum(val){
#	command = ("echo \"" val "\" | md5sum | sed 's/\\s.*//'");
#	command | getline ret;
#	close(command);
#	return ret;
#}

