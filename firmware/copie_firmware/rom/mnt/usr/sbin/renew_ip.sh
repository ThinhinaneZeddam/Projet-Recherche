#!/bin/sh

[ -e /tmp/.requesting_ip ] && return 0 || touch /tmp/.requesting_ip

uci set dhcpc.udhcpc.ip_requested=0;uci commit dhcpc

#wlan is on or not
wlan=$1
#wlan connect cnt
wlan_reconnect_count=$2
_c=0
_k=0
ip_requested=$(uci get dhcpc.udhcpc.ip_requested)
udhcpc_cmd=$(awk '{ORS=" "}{print $0}' /proc/$(pgrep udhcpc)/cmdline)

while [ $ip_requested = 0 ]
do
	#restart udhcpc when ip is not got for more than 60s
	if [ $_c -gt 3 ]; then
		killall -9 udhcpc
		$udhcpc_cmd &
		_c=0
		_k=$((_k+1))
	else
		killall -USR1 udhcpc
	fi
	_c=$((_c+1))
	#restart wlan0 when wlan is on and ip is not got for more than 90s
	if [ $wlan = 1 -a $_k -gt 2 ]; then
		ifconfig wlan0 down
		ifconfig wlan0 up
		_k=0
	fi
	sleep 15
	ip_requested=$(uci get dhcpc.udhcpc.ip_requested)
done

rm -f /tmp/.requesting_ip
