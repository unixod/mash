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
#  mail_parser.awk - Reads raw-mail data from stdin and extracts from it to
#                    subject and body to stdout.


BEGIN {
	FS = ": ";
	head = 1;
	multipart_boundary = 0;
	subject = "";
}


# Body
!head && (!multipart_boundary || ($0 !~ multipart_boundary)){
	# non empty lines are output
	# sybject must be set
	if(subject && $0) print;
}

# Body separator
(head == 1) && $0 == ""{
	head = 0;
}

# Multipart separator (optional)
multipart_boundary && ($0 ~ multipart_boundary){
	if(!--head) exit;
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
			print msg > "/dev/stderr";
			exit;
		}
	}
}


