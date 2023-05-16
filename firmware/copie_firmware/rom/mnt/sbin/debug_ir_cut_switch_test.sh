#!/bin/sh

IR_PIDFILE="/tmp/ir_cut_switch_test.pid"
PTZ_PIDFILE="/tmp/ptz_test.pid"
SP_PIDFILE="/tmp/speaker_test.pid"

if [ -s "${IR_PIDFILE}" ]; then
        SPID=`cat ${IR_PIDFILE}`
        if [ -e "/proc/${SPID}/status" ]; then
                echo "Ir cut switch test restart"
                kill ${SPID}
        fi
        cat /dev/null > ${IR_PIDFILE}
fi
echo $$ > ${IR_PIDFILE}

usage()
{
        echo -e "Usage: $0 [switchInterval] [switchTimes]"

        echo -e "\t[switchInterval] means the interval of IR-CUT switch"
		echo
        echo -e "\t[switchTimes] means the times of IR-CUT switch"
		echo
        echo -e "Example: $0 1 2"
        exit 0
}

if [ -z $1 -o $1 = "-h" -o $# -lt 2 ]; then
	usage
fi

fmt='{"method":"multipleRequest","params":{"requests":[{"method":"setDayNightModeConfig","params":{"image":{"common":{"inf_type":"%s"}}}}]}}'
cp /etc/config/image /tmp/.backup_image
rm -f /bin/uc_convert
rm -f /usr/lib/libuc_convert.so
i=0
while [ $i -lt $2 ]
do
	echo "ir_cut switch on" > /dev/console
	dsdSendCmd.sh -t $(printf "$fmt" "on")
	sleep $1
	
	echo "ir_cut switch off" > /dev/console
	dsdSendCmd.sh -t $(printf "$fmt" "off")
	sleep $1
	i=$((i+1))
done
dsdSendCmd.sh -t $(printf "$fmt" "auto")
mv /tmp/.backup_image /etc/config/image
[ -s "${PTZ_PIDFILE}" ] && PTZ_SPID=`cat ${PTZ_PIDFILE}`
[ -s "${SP_PIDFILE}" ] && SP_SPID=`cat ${SP_PIDFILE}`
[ ! -e "/proc/${PTZ_SPID}/status" -a ! -e "/proc/${SP_SPID}/status" ] && { cp /rom/bin/uc_convert /bin/uc_convert; cp /rom/usr/lib/libuc_convert.so /usr/lib/libuc_convert.so; }

cat /dev/null > ${IR_PIDFILE}
