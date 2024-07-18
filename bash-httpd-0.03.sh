#!/bin/bash
# Configurable variables
PATH=/bin:/usr/bin:/usr/local/bin
DOC_ROOT=~/Downloads/bash-httpd/www/
DEF_HTML=index.html
DEF_DIR=www
LOG_FACILITY=local1
# End of configurables
HTTP_VERSION="HTTP/1.0"
SERVER="bash-httpd/0.04"

CR=`printf "\015"`
program="${0##/*/}"

response_code(){
	num="$1"
	case "$num" in
		200) err="OK";;
		403) err="Forbidden";;
		404) err="Not Found";;
		500) err="Internal Server Error";;
		501) err="Not Implemented";;
		*)   err="Internal Server Error"
			log err "Unknown response: $num"
			num=500
			;;
	esac
	log notice "response: $num"
	echo "$HTTP_VERSION $num $err"
}

error(){
	response_code $1
	if [ "$2" ]; then problem="$2"; else problem="$err"; fi
cat <<EOF
Content-Type: text/html
<!DOCTYPE html><html><head><meta http-equiv="content-type" content="text/html; charset=utf-8" /><title> $problem </title></head><body><h1> $num $problem </h1> $problem </body></html>
EOF
	log err "$problem"
	exit 1
}

log(){
	level="$1"; message="$2"
	logger -p $LOG_FACILITY."$level" "$program[$$]: $method $url $version: $message"
}

read method url version

method="${method%$CR}";
url="${url%$CR}";
version="${version%$CR}";

case "$version" in
	""|http/0.9|HTTP/0.9) 
		readmore=0;;
	http/1.0|HTTP/1.0|http/1.1|HTTP/1.1)
		readmore=1;;
	*)
		log notice "$method $url $version"
		error 501 "Unknown version";;
esac

if [ "$readmore" != 0 ]; then
	read foo; while [ "$foo" != "$CR" -a "$foo" != "" ]; do read foo; done
fi

case "$method" in
	GET|get) 
		what=get;;
	HEAD|head) 
		what=head;;
	*)
		error 501 "Unimplemented method";;
esac

case "$url" in
	*/../*|*[^/A-Za-z0-9~.-]*) 
		error 403 "Illegal attempt to access resource"
		;;
	/~*)
		user="${url#/~}";
		user="${user%%/*}";
		user=`eval echo ~$user`; # we had *better* have cleaned up $url
		rest="${url#/~*/}"; rest="${rest##/~*}";
		type=file; file="$user/$DEF_DIR/$rest"
		;;
	""|/*)
		type=file; file="$DOC_ROOT/$url"
		;;
	*) 
		error 501 "Unknown request type"
		;;
esac

case $type in 
	file)
		if [   -d "$file" ]; then file="$file/$DEF_HTML"; fi
		if [ ! -e "$file" ]; then error 404; fi
		if [ ! -r "$file" ]; then error 403; fi
		response_code 200
		if [ "$what" = "head" ]; then echo; exit 0; fi
		case "$file" in
			*.html | *.htm)	mime=text/html;;
			*.jpg|*.jpeg)	mime=image/jpeg;;
			*.gif) 		mime=image/gif;;
			*.gz|*.tgz)	mime=application/binary;;
			*.txt|*.text)	mime=text/plain;;
			*.css)	mime=text/css;;
			*.js)	mime=text/javascript;;
			*.json)	mime=application/json;;
			*)		mime=application/binary;;
		esac
		echo Content-Type: $mime; echo; cat $file
		;;
	*)
		error 501 "Messed up internal type"
		;;
esac
