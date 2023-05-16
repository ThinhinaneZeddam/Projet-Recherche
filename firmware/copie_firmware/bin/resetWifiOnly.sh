#!/bin/sh

disable_ffs()
{
	echo ">> DISABLE FFS" > /dev/console
	rm -f /usr/bin/ffs
	pgrep ffs >/dev/null && {
		killall ffs
	}
}

reset_wlan_config()
{
	echo ">> RESET STA CONFIG" > /dev/console
	uci set wlan.ap0.on_boot=on
	uci set wlan.sta0.on_boot=on
	uci set wlan.sta0.connect_onboot=off
	uci delete wlan.sta0.ssid
	uci delete wlan.sta0.bssid
	uci delete wlan.sta0.key
	uci commit wlan
	echo "connected" > /tmp/.led_wifi_status
}

reset_to_softap()
{
	echo ">> RESET TO SOFTAP" > /dev/console
	uci set wlan.ap0.on_boot=on
	uci set wlan.sta0.on_boot=on
	uci set wlan.sta0.connect_onboot=off
	uci delete wlan.sta0.ssid
	uci delete wlan.sta0.bssid
	uci delete wlan.sta0.key
	uci commit wlan
	killall udhcpc udhcpd hostapd onboarding
	/etc/init.d/wlan-manager restart
	pgrep cloud-service >/dev/null || {
		/etc/init.d/cloud_service start
	}
	pgrep cloud-brd >/dev/null || {
		/etc/init.d/cloud_sdk start
	}
	pgrep cloud-client >/dev/null || {
		/etc/init.d/cloud_client start
	}
	pgrep relayd >/dev/null || {
		/etc/init.d/relayd start
	}
	pgrep rtspd >/dev/null || {
		/etc/init.d/rtspd start
	}
	pgrep ntpd >/dev/null || {
		/etc/init.d/sysntpd start
	}
}

set_reset_wifi_flag()
{
	echo ">> SET RESETWIFI FLAG" > /dev/console
	uci set system.sys.is_reset_wifi=1
	uci commit system
}

disable_ffs
[ `cat /sys/class/net/eth0/carrier` = 1 ] && {
	reset_to_softap
	set_reset_wifi_flag
	return
}

reset_to_softap
set_reset_wifi_flag