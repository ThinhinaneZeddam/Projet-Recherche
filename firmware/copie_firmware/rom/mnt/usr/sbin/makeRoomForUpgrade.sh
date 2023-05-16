#!/bin/sh
SUCCESS=0
ERR_OUT_OF_ABILITY=1
MAKEROOM_STATUS=system.sys.makeroom_status

wtd_ctrl()
{
	if [ "$1" == "start" ]; then
		ubus call wtd sw_wtd_start
	fi

	if [ "$1" == "stop" ]; then
		ubus call wtd sw_wtd_stop
	fi

	return $SUCCESS
}

#check_freeMem memexpect check_count
check_freeMem()
{
	count=0
	while [ $count -lt $2 ]
	do
		curFree=$(awk '/MemFree/{free=$2}/^Cached/{cached=$2}/Buffers/{buffers=$2}END{print (free + cached + buffers)}' /proc/meminfo)
		if [ $curFree -ge $1 ]; then
			echo "free expect memory, expect:$1, current:$curFree">/dev/console
			return $SUCCESS
		fi

		let count=$count+1
		sleep 1
	done

	echo "memfree is not enough, expect:$1, current:$curFree">/dev/console
	return 1
}

kill_process()
{
	# make room init
	uci set $MAKEROOM_STATUS=0

	expect=$(($tarSize+$minReserve))
	echo "$expect k memory is expected">/dev/console

	#stop wtd detection
	wtd_ctrl stop

	# make room working
	uci set $MAKEROOM_STATUS=1

	if [ -e /etc/wifi-ethernet-switch ]; then
		killall wifi-ethernet-switch
	fi

	/etc/init.d/rcS T terminate

	which disable_hw_wtd && disable_hw_wtd

	check_freeMem $expect 10
	if [ $? -eq $SUCCESS ];then
		# make room success
		uci set $MAKEROOM_STATUS=2
		return $SUCCESS
	else
		# make room failed, resume process
		resume_process

		uci set $MAKEROOM_STATUS=3
		return $ERR_OUT_OF_ABILITY
	fi
}

resume_process()
{
	/etc/init.d/rcS R resume

	#restart wtd detection
	wtd_ctrl start

	return $SUCCESS
}

if [ "$1" == "kill" ]; then
	#${variable:-word}   Use new value if undefined or null
	tarSize=$((${2:-17000000}/1024))
    minReserve=${3:-4000}

    kill_process
elif [ "$1" == "resume" ]; then
    resume_process
else
    echo "wrong parameters!"
fi
