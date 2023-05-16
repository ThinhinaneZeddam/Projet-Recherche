#!/bin/sh

# wtd cloud-client cloud-sdk cloud-service will be killed
# bind info will be saved
slprestore -f
# udhcpc udhcpd hostapd onboarding started by wlan-manager
# killall udhcpc udhcpd hostapd onboarding

# do not restart wlan-manager
must_restart="cfgmac cfgdev_info cloud_sdk cloud_client cloud_service cet nvid wtd ledd"                                    
for file in $must_restart;do                                              
    /etc/init.d/$file stop
done

c=0
while pgrep cet >/dev/null
do
	sleep 1
	c=$((c+1))
	[ $c -gt 15 ] && reboot
done

for file in $must_restart;do                                              
    /etc/init.d/$file start
done

sleep 1

if [ `cat /sys/class/net/eth0/carrier` = 1 ]; then
	echo "connected" > /tmp/.led_wifi_status
else
	ubus send wlan_event '{"wlan_state":"hostap_up"}'
fi

# ubus call
ubus call storage_manager reload_config