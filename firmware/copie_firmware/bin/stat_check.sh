#!/bin/sh

# Version v1.2 20180115
# Used to check programs' memory usage.

# Changes and History:
# v1.2	- change to run continuously instead of exit when specified prog stopped
#		  no longer support checking scripts named like ***.sh

# License and Copyright:
# You can use, redistribute or modify this script in all cases for free.

selfprog=`basename $0`
intervaltime=60

usage()
{
	echo "************Author: Elroy************"
	echo "$selfprog [--prog ProgName|--pid PidNumber] [-p [-t S]] [-f [-c] [-d]] [-n]"
	echo -e "\tuse either --prog or --pid to specify progs, which can be more than one."
	echo -e "\tif none specified, will check all running progs."
	echo -e "\t-p is to check persistently, default: only once."
	echo -e "\t-t is to check in S sec, default: 60, will not take effect without -p."
	echo -e "\t-f is to print freemem, default: not."
	echo -e "\t-c is to clean caches before check memory, default: not, will not take effect without -f."
	echo -e "\t-d is to print memory used by module drivers, default: not, will not take effect without -f."
	echo -e "\t-n is to print netstat, default: not."
	exit 0
}

check_number()
{
	[ -n "`echo $1 | sed -e 's/[0-9]*//g'`" ] && usage
}

check_time()
{
	[ $1 -lt 0 -o $1 -gt 3600 ] && usage
}

err_notrunning()
{
	echo "prog $ProgName is not running"
	usage
}

while [ $# -ge 1 ]
do

	case $1 in
		--prog)
			[ -z "$2" ] && usage
			ProgName=$2
			PidNumber=`ps | grep $ProgName | grep -vE "grep|\.sh" | awk '{print $1}'`
			[ -z "$PidNumber" ] && err_notrunning
			Specified_prog=1
			ProgNames="$ProgNames $ProgName"
			PidNumbers="$PidNumbers $PidNumber"
			shift;shift
			;;
		--pid)
			[ -z "$2" ] && usage
			PidNumber=$2
			check_number $PidNumber
			ProgName=`cat /proc/$PidNumber/status 2>/dev/null | awk '$1=="Name:"{print $2}'`
			[ -z "$ProgName" ] && err_notrunning
			Specified_prog=1
			ProgNames="$ProgNames $ProgName"
			PidNumbers="$PidNumbers $PidNumber"
			shift;shift
			;;
		-v)
			vm_print=1
			shift
			;;
		-p)
			Persistent=1
			shift
			;;
		-t)
			[ -z "$2" ] && usage
			intervaltime=$2
			check_number $intervaltime
			check_time $intervaltime
			shift;shift
			;;
		-f)
			FreeMem=1
			shift
			;;
		-c)
			CleanCaches=1
			shift
			;;
		-d)
			DriverMemory=1
			shift
			;;
		-n)
			Netstat=1
			shift
			;;
		*)
			usage
			;;
	esac
done

while :
do
	if [ -z "$Specified_prog" ];then
		PIDS=`ps | grep -vE "\[|\.sh" | grep -vwE "PID|grep|ps|awk" | awk 'BEGIN{ORS=" "}{print $1}'`
	else
		i=0
		for pid in $PidNumbers
		do
			i=$((i+1))
			[ -e /proc/$pid ] || {
				PidNumbers=`echo $PidNumbers | awk -v i=$i 'BEGIN{ORS=" "}{for(j=1;j<=NF;j++)if(j!=i){print $j}else{print 0}}'`
				prog=`echo $ProgNames | awk -v i=$i '{print $i}'`
				pid=`ps|grep -w $prog|grep -vE "grep|\.sh"|awk '{print $1}'`
				[ -z "$pid" ] && echo "$prog is not running!" || {
					echo "------$prog pid has changed"
					PidNumbers=`echo $PidNumbers | awk -v i=$i -v pid=$pid 'BEGIN{ORS=" "}{for(j=1;j<=NF;j++)if(j!=i){print $j}else{print pid}}'`
					ProgNames=`echo $ProgNames | awk -v i=$i -v prog=$prog 'BEGIN{ORS=" "}{for(j=1;j<=NF;j++)if(j!=i){print $j}else{print prog}}'`
				}
			}
		done
		PIDS=$PidNumbers
	fi
	echo -ne "PID\tPROGNAME\tMEMUSED(kB)\tSTAT\tTHREAD\tFD"
	[ "$vm_print" = "1" ] && echo -ne "\tVmHWM\tVmPeak\tVmSize"
	echo -ne "\n"
	total=0
	for pid in $PIDS
	do
		#eval `echo "name= mem=;";grep -E "Name:|VmRSS:" /proc/$pid/status 2>/dev/null | sed -e 's/.*Name:[[:space:]]*\(.*\)/name=\1/g;s/.*VmRSS:[[:space:]]*\([0-9]\+\).*/mem=\1/g'`
		name=`awk '$1=="Name:"{print $2}' /proc/$pid/status 2>/dev/null`
		mem=`awk '$1=="VmRSS:"{print $2}' /proc/$pid/status 2>/dev/null`
		[ "$vm_print" = "1" ] && {
			vmHWM=`awk '$1=="VmHWM:"{print $2}' /proc/$pid/status 2>/dev/null`
			vmPeak=`awk '$1=="VmPeak:"{print $2}' /proc/$pid/status 2>/dev/null`
			vmSize=`awk '$1=="VmSize:"{print $2}' /proc/$pid/status 2>/dev/null`
		}
		stat=`awk '{print $3}' /proc/$pid/stat 2>/dev/null` tasknum=`ls /proc/$pid/task 2>/dev/null|wc -l` maxfd=`ls /proc/$pid/fd 2>/dev/null|wc -l`
		if [ -n "$mem" ];then
			echo -ne "$pid\t$name\t"
			[ ${#name} -lt 8 ] && echo -ne "\t"
			echo -ne "$mem\t\t$stat\t$tasknum\t$maxfd"
			[ "$vm_print" = "1" ] && echo -ne "\t$vmHWM\t$vmPeak\t$vmSize"
			echo -ne "\n"
			total=$((total+mem))
		fi
	done
	echo -ne "/\tTOTAL\t\t$total\t\t/\t/\t/"
	[ "$vm_print" = "1" ] && echo -ne "\t/\t/\t/"
	echo -ne "\n"

	if [ -n "$FreeMem" ];then
		[ -n "$CleanCaches" ] && { sync; echo 3 > /proc/sys/vm/drop_caches; }
		eval `grep Mem /proc/meminfo | sed -e 's/.*MemTotal:[[:space:]]*\([0-9]\+\).*/memtotal=\1/g;s/.*MemFree:[[:space:]]*\([0-9]\+\).*/memfree=\1/g'`
		echo -ne "meminfo(kB): total=$memtotal, free=$memfree, used=$memtotal-$memfree=$((memtotal-memfree))\n"
		[ -n "$DriverMemory" ] && { drivermem=0; for _m in `lsmod|grep -v Module|awk '{print $2}'`; do drivermem=$((drivermem+_m)); done; echo -ne "driver memory used(kB): $((drivermem/1024))\n"; }
	fi

	if [ -n "$Netstat" ];then
		echo -ne "netstat:\n"
		netstat -npl 2>/dev/null | awk '$1~"tcp"{print $1,$4,$7} $1~"udp"{print $1,$4,$6} $1~"unix"{print $1,$10,$9}'| awk '{len=length($1)+length($2)+2;if(len<16){print "("$1")"$2"\t\t\t"$3}else if(len<24){print "("$1")"$2"\t\t"$3}else{print "("$1")"$2"\t"$3}}'
	fi
	[ -z "$Persistent" ] && break || { sleep $intervaltime; echo "=========================================================="; }
done