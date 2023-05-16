#!/bin/sh

shellname="resetWaitUnbind"
local max_wait_second=5

# check need_bind status before reset
username=`uci get cloud_config.bind.username`
if [ -n "${username}" ]; then
	need_bind=`uci get cloud_config.extra_bind.need_bind`
	if [ ${need_bind} = "0" ]; then
		echo -e "[${shellname}] Device not unbind, wait..." > /dev/console
		uci set cloud_status.unbind.owner=1
		uci set cloud_status.unbind.action_status=2
		uci set cloud_status.unbind.err_code=0
		uci commit cloud_status
		ubus call cloudclient user_unbind '{"user_conf_path": "cloud_config"}'	
	else
		echo -e "[${shellname}] Device neither unbind the old account nor bind the new account," > /dev/console
		echo -e "               new account info will be discarded after reset." > /dev/console
		slprestore -rf
		return
	fi
else
	echo -e "[${shellname}] Device has been unboud, reset" > /dev/console
	slprestore -rf
	return
fi

# wait for unbind before reset
for  sec_cnt in `seq ${max_wait_second}`; do
	if [ -n "${username}" ]; then
		echo -e "[${shellname}] wait for unbound, sec: ${sec_cnt}s/${max_wait_second}s" > /dev/console
	else
		echo -e "[${shellname}] Device unbind finish, reset" > /dev/console
		break
	fi
	sleep 1
	username=`uci get cloud_config.bind.username`
done

if [ ${sec_cnt} -ge ${max_wait_second} ]; then
	echo -e "[${shellname}] Device unbind failed, reset." > /dev/console
fi

slprestore -rf