#!/bin/sh

myscript="$1"
if [ -L $1 ] ; then
	myservice=$(readlink "$1")
else
	myservice=$1
fi

myservice=`basename ${myservice}`
export SVCNAME=${myservice}

[ "$RC_GOT_FUNCTIONS" ] || . /sbin/functions.sh

# wrapper for busybox killall
killall() {
	local flags ka
	ka=`which killall`
	while [ $# -gt 0 ] ; do
		case "$1" in
			-*)	flags="$flags $1";;
			*)	flags="$flags `basename $1`"
		esac
		shift
	done
	$ka $flags
}

svc_start() {
	start
}

svc_stop() {
	stop
}

svc_status() {
	status
}

restart() {
	svc_stop
	sleep 1
	svc_start
}

usage() {
	local i uopts
	for i in $opts; do
		uopts="$uopts|$i"
	done
	echo "usage: $myscript start|stop|status|restart$uopts"
	exit $1
}		

[ -f "/etc/conf.d/$myservice" ] && . "/etc/conf.d/$myservice"
. "$myscript"

shift
if [[ $# -lt 1 ]] ; then
	usage 1
fi

for arg in $* ; do
	case "${arg}" in
	start)	
		svc_start
		;;
	stop)
		svc_stop
		;;
	status)
		svc_status
		;;
	restart)
		restart
		;;
	*)		
		for opt in $opts ; do
			[ "$arg" = "$opt" ] && $arg
		done
		;;
	esac
done
	