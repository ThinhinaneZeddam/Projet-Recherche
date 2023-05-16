#!/bin/sh

ifname=wlan0

base64_encode() {
	echo -n $1 | base64
}

get_bssid_by_ssid() {
	ifconfig -a 2>/dev/null | grep -q $ifname || ubus call wlan_manager wlan_sta_start
	ifconfig 2>/dev/null | grep -q $ifname || ifconfig $ifname up >/dev/null 2>&1
	iwlist $ifname scan | grep -B1 $1 | awk '$(NF-1)=="Address:"{print $NF}'
}

start_softap() {
	uci set wlan.ap0.on_boot=on
	uci set wlan.sta0.on_boot=on
	uci set wlan.sta0.connect_onboot=off
	uci delete wlan.sta0.ssid
	uci delete wlan.sta0.bssid
	uci delete wlan.sta0.key
	uci commit wlan
	ubus call wlan_manager wlan_ap_restart
	ubus call wlan_manager wlan_ap_restart '{"reload_driver":0}'
	ubus call wlan_manager wlan_sta_restart '{"reload_driver":0}'
}

start_station() {
	local ssid="${1:-NOSSID}"
	ssid=$(base64_encode $ssid)
	local bssid=$(get_bssid_by_ssid $ssid)
	local password="${2}"
	password=$(base64_encode $password)
	ubus call wlan_manager wlan_sta_connect "{ \"ssid\":\"$ssid\", \"bssid\":\"$bssid\", \"auth\":4, \"encryption\":3, \"password\":\"$password\" }"
	ubus call wlan_manager wlan_sta_restart
	uci set wlan.ap0.on_boot=off
	uci set wlan.sta0.on_boot=on
	uci set wlan.sta0.connect_onboot=on
	uci commit wlan
}

start_wpa3_station() {
	local ssid="${1:-NOSSID}"
	ssid=$(base64_encode $ssid)
	local bssid=$(get_bssid_by_ssid $ssid)
	local password="${2}"
	password=$(base64_encode $password)
	ubus call wlan_manager wlan_sta_connect "{ \"ssid\":\"$ssid\", \"bssid\":\"$bssid\", \"auth\":5, \"encryption\":3, \"password\":\"$password\" }"
	ubus call wlan_manager wlan_sta_restart
	uci set wlan.ap0.on_boot=off
	uci set wlan.sta0.on_boot=on
	uci set wlan.sta0.connect_onboot=on
	uci commit wlan
}

case $1 in
	sta|STA|station|STATION)shift 1 && start_station "$@";;
	wpa3) shift 1 && start_wpa3_station "$@";;
	ap|AP|master|MASTER|open|OPEN)shift 1 && start_softap "$@";;
	*)start_softap "$@";;
esac
