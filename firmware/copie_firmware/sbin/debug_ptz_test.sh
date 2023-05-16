#!/bin/sh

PTZ_PIDFILE="/tmp/ptz_test.pid"
IR_PIDFILE="/tmp/ir_cut_switch_test.pid"
SP_PIDFILE="/tmp/speaker_test.pid"

if [ -s "${PTZ_PIDFILE}" ]; then
        SPID=`cat ${PTZ_PIDFILE}`
        if [ -e "/proc/${SPID}/status" ]; then
                echo "Ptz test restart"
                kill ${SPID}
        fi
        cat /dev/null > ${PTZ_PIDFILE}
fi
echo $$ > ${PTZ_PIDFILE}

usage()
{
        echo -e "Usage: $0 [testMode] [times] [[start_x_coord] [start_y_coor] [end_x_coord] [end_y_coor]]"

        echo -e "\t[testMode] must be in the range below:"
        echo -e "\t 0:\t mode 0: Out of step test, out of step test needs to input parameters of rotation range from (start_x_coord, end_x_coord) to (end_x_coord, end_y_coor)"
        echo -e "\t 1:\t mode 1: Life test, ptz will turn to the limit position and come back from (-170, -32) to (170, 35)"
		echo 
		echo -e "\t[times] means the times of ptz test"
		echo
        echo -e "\t[start_x_coord] means the x coordinates of start position"
		echo
		echo -e "\t[start_y_coor] means the y coordinates of start position"
		echo
		echo -e "\t[end_x_coord] means the x coordinates of end position"
		echo
		echo -e "\t[end_y_coor] means the y coordinates of end position"
		echo
        echo -e "Example: $0 0 2 -135 -20 135 20"
        echo -e "Example: $0 1 2"
        exit 0
}

if [ -z $1 -o $1 = "-h" -o $# -lt 2 ]; then
	usage
fi

test_ptz_stop()
{
	ubus call PTZ get_status > /tmp/.motord_getStatus_result
	x_speed=`cat /tmp/.motord_getStatus_result | sed -e 's/"//g;s/,//g;s/ //g' | awk -F: '$1~"status_pan"{print $2}'`
	y_speed=`cat /tmp/.motord_getStatus_result | sed -e 's/"//g;s/,//g;s/ //g' | awk -F: '$1~"status_tilt"{print $2}'`
	rm -f /tmp/.motord_getStatus_result
	[ "$x_speed" = "idle" -a "$y_speed" = "idle" ] && return 0 || return 1
}

goto_x_y()
{
	ubus call PTZ absolute_move "{\"position_pan\":\"$1\",\"position_tilt\":\"$2\"}"
}

times=$2
x_s=-1.0
x_e=1.0
y_s=-1.0
y_e=1.0

cp /etc/config/ptz /tmp/.backup_ptz
rm -f /bin/uc_convert
rm -f /usr/lib/libuc_convert.so
if [ $1 -eq 0 ]; then
	echo "mode 0: Out of step test" > /dev/console
	echo "move From position ($3, $4) To position: ($5, $6)" > /dev/console

	i=0
	while [ $i -lt $times ]
	do
		goto_x_y $3 $4
		echo "Reset to position ($3, $4)" > /dev/console
		sleep 3
		while :; do test_ptz_stop && break; sleep 1;done
		
		goto_x_y $5 $6
		echo "Move to position ($5, $6)" > /dev/console
		sleep 3
		while :; do test_ptz_stop && break; sleep 1;done

		i=$((i+1))
		echo "done" > /dev/console
	done

	echo "Number of turns: $i" > /dev/console
	
	
elif [ $1 -eq 1 ]; then
	echo "mode 1: Life test" > /dev/console

	j=0
	while [ $j -lt $times ]
	do
		goto_x_y $x_s $y_s
		echo "Reset to position ($x_s, $y_s)" > /dev/console	
		sleep 3
		while :; do test_ptz_stop && break; sleep 1;done

		goto_x_y $x_e $y_e
		echo "Move to position ($x_e, $y_e)" > /dev/console		
		sleep 3
		while :; do test_ptz_stop && break; sleep 1;done

		j=$((j+1))
		echo "done" > /dev/console
	done

	echo "Number of turns: $j" > /dev/console

else
	echo "Wrong command input, please try again" > /dev/console
fi
mv /tmp/.backup_ptz /etc/config/ptz
[ -s "${IR_PIDFILE}" ] && IR_SPID=`cat ${IR_PIDFILE}`
[ -s "${SP_PIDFILE}" ] && SP_SPID=`cat ${SP_PIDFILE}`
[ ! -e "/proc/${IR_SPID}/status" -a ! -e "/proc/${SP_SPID}/status" ] && { cp /rom/bin/uc_convert /bin/uc_convert; cp /rom/usr/lib/libuc_convert.so /usr/lib/libuc_convert.so; }

cat /dev/null > ${PTZ_PIDFILE}
