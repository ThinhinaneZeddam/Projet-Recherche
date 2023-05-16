#!/bin/sh

LOG_PRIO_ALL=0
LOG_PRIO_DEBUG=1
LOG_PRIO_INFO=2
LOG_PRIO_NOTICE=3
LOG_PRIO_WARNING=4
LOG_PRIO_ERROR=5
LOG_PRIO_EMERGENT=6
LOG_PRIO_MAX=7

msglog()
{
	if [ 3 -ne $# ]
	then
	echo "usage : ${fname} priotry model info"
	echo "example:${fname} 1 DHCP releasexxx"
	return 1
	fi

	ubus call msglog write "{\"priority\":$1, \"type\":\"$2\", \"info\":\"$3\"}"
	return $?
}

