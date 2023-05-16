#########################################################
# Copyright (C) 2015 TP-LINK Technologies CO.,LTD.
#
# FILE NAME  :   parse_uci_config.sh
# VERSION    :   1.0
# DESCRIPTION:   use to parse json in the env $UCI_CONFIG
# AUTHOR     :   linzhifeng <linzhifeng@tp-link.net>
#
#########################################################
. /usr/share/libubox/jshn.sh
UCI_PREFIX='UCI_CONFIG_'

_json_reset() {
	json_select
	json_set_namespace
}

load_uci_config() {
	json_set_namespace $UCI_PREFIX
	local JSON="$UCI_CONFIG"

	if [ -n "$JSON" ]; then
		json_load "$JSON"
		json_set_namespace
		return 0
	else
		json_set_namespace
		return 1
	fi
}

uci_name_is() {
	json_set_namespace $UCI_PREFIX
	json_is_a $1 object
	local ret=$?
	json_set_namespace
	return $ret
}

get_uci_name() {
	json_set_namespace $UCI_PREFIX
	local uci

	#使用了/usr/share/libubox/jshn.sh的内部接口和环境变量
	#jshn.sh的函数接口不满足需求
	_json_get_var uci "KEYS_JSON_VAR"

	echo "$uci"
	json_set_namespace
	[ -n "$uci" ] && return 0 || return 1
}

get_sections_name() {
	json_set_namespace $UCI_PREFIX
	local tmp

	json_get_var tmp $1

	if [ -n "$tmp" ]; then
	#使用了/usr/share/libubox/jshn.sh的内部接口和环境变量
	#jshn.sh的函数接口不满足需求
		_json_get_var tmp "KEYS_$tmp"
		echo "$tmp"
	fi
	json_set_namespace
	[ -n "$tmp" ] && return 0 || return 1
}

get_sections_type() {
	json_set_namespace $UCI_PREFIX
	local names=$(get_sections_name $1)
	local uci=$1
	local types
	local type
	local tmp

	for name in $names
	do
		type=$(/sbin/uci get $uci'.'$name -q)
		if [ -z "$type" ]; then
			json_get_type tmp $uci
			[ "$tmp" != object ] && _json_reset && return 1

			json_select $uci
			json_get_type tmp $name
			[ "$tmp" != object ] && _json_reset && return 1

			json_select $name
			json_get_type tmp "type"
			[ "$tmp" != string ] && _json_reset && return 1

			json_get_var type "type"

			json_select
		fi
		types=${types:+$types }$type
	done

	json_set_namespace
	[ -n "$types" ] && echo "$types" | xargs -n 1 echo | sort -u || return 1
}

method_in_section() {
	json_set_namespace $UCI_PREFIX
	local uci=$1
	local section=$2
	local tmp
	local method

	json_get_type tmp $uci
	[ "$tmp" != object ] && _json_reset && return 1

	json_select $uci
	json_get_type tmp $section
	[ "$tmp" != object ] && _json_reset && return 1

	json_select $section
	json_get_type tmp "method"
	[ "$tmp" != string ] && _json_reset && return 1

	json_get_var method "method"

	echo "$method"

	_json_reset
}

get_an_option() {
	json_set_namespace $UCI_PREFIX
	local uci=$1
	local section=$2
	local option=$3
	local tmp
	local value

	json_get_type tmp $uci
	[ "$tmp" != object ] && _json_reset && return 1

	json_select $uci
	json_get_type tmp $section
	[ "$tmp" != object ] && _json_reset && return 1

	json_select $section
	json_get_type tmp "para"
	[ "$tmp" != object ] && _json_reset && return 1

	json_select "para"
	json_get_var value $option
	[ -z "$value" ] && _json_reset && return 1

	echo "$value"

	_json_reset
}
