#!/bin/sh

SP_PIDFILE="/tmp/speaker_test.pid"
IR_PIDFILE="/tmp/ir_cut_switch_test.pid"
PTZ_PIDFILE="/tmp/ptz_test.pid"

if [ -s "${SP_PIDFILE}" ]; then
        SPID=`cat ${SP_PIDFILE}`
        if [ -e "/proc/${SPID}/status" ]; then
                echo "Speaker test restart"
                kill ${SPID}
        fi
        cat /dev/null > ${SP_PIDFILE}
fi
echo $$ > ${SP_PIDFILE}

usage()
{
        echo -e "Usage: $0 [playInterval] [volume] [playTimes]"
	echo -e "\t[playInterval] means the interval of audio playback"
	echo
	echo -e "\t[volume] means the volume of audio playback"
	echo
        echo -e "\t[playTimes] means the times of audio playback"
        echo
        echo -e "\t audioType must be in the range below:"
        echo -e "\t 0:\t wlan_state_connect_suc: \"wifi connected\""
        echo -e "\t 1:\t wlan_state_connecting: \"connecting wifi\""
        echo -e "\t 2:\t wlan_state_password_err: \"incorrect wifi password\""
        echo -e "\t 3:\t wlan_state_get_ip_fail: \"fail to receive ip address\""
        echo -e "\t 4:\t wlan_state_mode_switch_suc: \"soft ap setup already selected\""
        echo -e "\t 6:\t sd_abnormal: \"there is problem with sd card\""
        echo -e "\t 7:\t reset_success: \"reset successful, rebooting camera, please wait\""
        echo -e "\t 10:\t motion_deteck_cue"
        echo -e "\t 11:\t motion_deteck_alarm"
        echo -e "\t 19:\t prompt_sd_card: \"sd card is not format, please format it according the app guidelines\""
        echo
        echo -e "Example: $0 1 80 1"
        exit 0
}

if [ -z $1 -o $1 = "-h" -o $# -lt 2 ]; then
	usage
fi
intv=$1
vol=$2
times=$3
echo "$times"

set 0 1 2 3 4 6 7 10 11 19

cp /etc/config/system_state_audio /tmp/.backup_system_state_audio
rm -f /bin/uc_convert
rm -f /usr/lib/libuc_convert.so
ubus call system_state_audio set_language "{\"language\":\"EN\"}"
i=0
while [ $i -lt $times ]
do
        for j in "$@";do
                echo "Playing audio type $j" > /dev/console
                ubus call system_state_audio audio_play "{\"id\":$j,\"vol\":$vol,\"interrupt\":0}"
                sleep 4
        done

	i=$((i+1))
	echo "done" > /dev/console
    sleep $intv
done
mv /tmp/.backup_system_state_audio /etc/config/system_state_audio
[ -s "${IR_PIDFILE}" ] && IR_SPID=`cat ${IR_PIDFILE}`
[ -s "${PTZ_PIDFILE}" ] && PTZ_SPID=`cat ${PTZ_PIDFILE}`
[ ! -e "/proc/${IR_SPID}/status" -a ! -e "/proc/${PTZ_SPID}/status" ] && { cp /rom/bin/uc_convert /bin/uc_convert; cp /rom/usr/lib/libuc_convert.so /usr/lib/libuc_convert.so; }

cat /dev/null > ${SP_PIDFILE}
