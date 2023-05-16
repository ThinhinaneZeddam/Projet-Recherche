#!/bin/sh
# Copyright (C) 2006-2011 OpenWrt.org

. /lib/functions.sh

apply_dst() {
	local enabled synced has_rule dst_start dst_end
	local dst_start_format dst_end_format
	local dst_local_start dst_local_end
	local timezone new_timezone

	config_load system
	config_get enabled dst enabled
	config_get synced dst synced
	config_get has_rule dst has_rule
	config_get dst_offset dst dst_offset
	config_get dst_local_start dst dst_local_start
	config_get dst_local_end dst dst_local_end
	config_get timezone basic timezone

	new_timezone=${timezone/+/-}
	if [ "$new_timezone"x = "$timezone"x ]; then
		new_timezone=${timezone/-/+}
	fi

	new_timezone=${new_timezone/UTC/GMT}

	if [ "$enabled" = "0" ] || [ "$synced" = "0" ] || [ "$has_rule" = "0" ]; then
		echo "$new_timezone"
		return 
	fi

	echo "$new_timezone$dst_offset,M$dst_local_start,M$dst_local_end"
}

update_timezone() {
	local zone_id

	config_load system
	config_get zone_id basic zone_id

	dst=`apply_dst`
	echo "$dst" > /tmp/TZ

	
	[ -n "$zone_id" ] && [ -f "/usr/share/zoneinfo/$zone_id" ] && ln -s "/usr/share/zoneinfo/$zone_id" /tmp/localtime

	# apply timezone to kernel
	date -k
}

update_timezone
