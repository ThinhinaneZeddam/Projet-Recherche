#!/bin/sh

input_json="$1"
status=

. /usr/share/libubox/jshn.sh

json_load "$input_json"
json_get_vars status

if [ "down" == $status ]; then
	ubus call tpServer cleanTMP
fi