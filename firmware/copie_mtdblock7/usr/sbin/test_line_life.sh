#!/bin/sh
is_ping_succesful() {
	fail_test_times=1
	while [ $fail_test_times -lt 3 ]; do
		if ping -c 1 "192.168.1.1" >/dev/null; then
			return 1
		else
			let fail_test_times++
		fi
	done
	if [ $fail_test_times -eq 3 ]; then
		echo "ERROR:cannt ping 192.168.1.1"
		return 0
	fi
}


usage() {
	cat <<EOF
Usage: $0 + motor_index(0:pan, 1:tilt, 2:pan and tilt) + move_time + move_idle_time (+test times +is_test_ping)
    $0 0 5 10----> test pan motor, move 5 second, idle 10 second
    $0 1 5  5----> test tilt motor, move 5 second, idle 5 second
    $0 2 5  5----> test pan/tilt motor, move 5 second, idle 5 second
    $0 0 5  5 100 ----> test pan motor 100 times, move 5 second, idle 5 second
    $0 0 5  5 100 1----> test pan motor and network cable 100 times, move 5 second, idle 5 second
EOF
	exit 1
}

i=1
ret1=0
ret2=0
ret3=0
test_times=100000
is_test_ping=0

#prepare
uci set ptz.manual_control_config.speed_level=high
uci set ptz.poweroff_save_config.save_time=600
uci commit ptz
ret1=$(ubus call PTZ reload_basic_config)
cur_time=$(date "+%Y-%m-%d %H:%M:%S")

#chack arguments validity
if [[ -n $1 && -n $2 && -n $3 ]];then
	expr $1 "+" 10 &> /dev/null
	ret1=$?
	expr $2 "+" 10 &> /dev/null
	ret2=$?
	expr $3 "+" 10 &> /dev/null
	ret3=$?
	if [[ $ret1 -ne 0 || $ret2 -ne 0 || $ret3 -ne 0 ]];then
		usage
	fi

	#test num
	if [[ -n $4 ]];then
		expr $4 "+" 10 &> /dev/null
		if [[ "$?" -eq 0 ]];then
			test_times=$4
		fi
	fi

	#whether test network cable
	if [[ -n $5 && "$5" -eq 1 ]];then
		let is_test_ping=1
	fi
else
	usage
fi

echo *************$cur_time motor test begin************

while [ $i -le $test_times ];do

	#test pan motor
	if [ $1 -eq 0 ];then
		cmd=$(echo "ubus call PTZ continuous_move '{\"speed_pan\":\"1\", \"speed_tilt\":\"0\", \"timeout\":\"$2"000\"}\')
		ret1=$(eval $cmd)
		sleep $2
		sleep $3

		cmd=$(echo "ubus call PTZ continuous_move '{\"speed_pan\":\"-1\", \"speed_tilt\":\"0\", \"timeout\":\"$2"000\"}\')
		ret1=$(eval $cmd)
		sleep $2
		sleep $3

	#test tilt motor
	elif [ $1 -eq 1 ];then
		cmd=$(echo "ubus call PTZ continuous_move '{\"speed_pan\":\"0\", \"speed_tilt\":\"1\", \"timeout\":\"$2"000\"}\')
		ret1=$(eval $cmd)
		sleep $2
		sleep $3

		cmd=$(echo "ubus call PTZ continuous_move '{\"speed_pan\":\"0\", \"speed_tilt\":\"-1\", \"timeout\":\"$2"000\"}\')
		ret1=$(eval $cmd)
		sleep $2
		sleep $3

	#test pan and tilt motor
	elif [ $1 -eq 2 ];then
		cmd=$(echo "ubus call PTZ continuous_move '{\"speed_pan\":\"1\", \"speed_tilt\":\"1\", \"timeout\":\"$2"000\"}\')
		ret1=$(eval $cmd)
		sleep $2
		sleep $3

		cmd=$(echo "ubus call PTZ continuous_move '{\"speed_pan\":\"-1\", \"speed_tilt\":\"-1\", \"timeout\":\"$2"000\"}\')
		ret1=$(eval $cmd)
		sleep $2
		sleep $3
	else
		cmd=$(echo "ubus call PTZ continuous_move '{\"speed_pan\":\"1\", \"speed_tilt\":\"0\", \"timeout\":\"$2"000\"}\')
		ret1=$(eval $cmd)
		sleep $2
		cmd=$(echo "ubus call PTZ continuous_move '{\"speed_pan\":\"-1\", \"speed_tilt\":\"0\", \"timeout\":\"$2"000\"}\')
		ret1=$(eval $cmd)
		sleep $2
		sleep $2
		cmd=$(echo "ubus call PTZ continuous_move '{\"speed_pan\":\"1\", \"speed_tilt\":\"0\", \"timeout\":\"$2"000\"}\')
		ret1=$(eval $cmd)
		sleep $2
	fi

	#test network cable
	if [[ $is_test_ping == 1 ]];then
		is_ping_succesful
		if [ "$?" == 0 ];then
			echo !!!!!!!!!!!!!!$(date "+%Y-%m-%d %H:%M:%S") motor test fail, test_times=$i!!!!!!!!!!!!!!
			break
		fi
	fi

	echo $cur_time to $(date "+%Y-%m-%d %H:%M:%S") test_times=$i

	let i=i+1
done
echo *************$(date "+%Y-%m-%d %H:%M:%S") motor test end************
