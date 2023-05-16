#!/bin/sh
# Copyright (C) 2006-2011 OpenWrt.org
                                 
pNone="\033[0m"
pForwardRed="\033[40;31m" 
pForwardBlue="\033[47;34m" 
pForwardGreen="\033[40;32m"  
pForwardPurple="\033[40;35m"                                     

usage()
{
        echo -e "$pForwardGreen Usage: $0 mode $pNone"
        echo -e "\t[mode] could be $pForwardPurple beta | beta2 | prod $pNone"
        echo -e "$pForwardGreen Example: $0 beta $pNone"
        exit 0
}

if [ -z $1 ] || [ $1 = "-h" ];then
	usage
fi 
restart_flag=0
if [ $1 = "prod" ];then
	uci set cloud_sdk.cloud.sefDomain=n-deventry-dcipc.tplinkcloud.com
	uci set cloud_sdk.cloud.defaultSvr=n-devs-dcipc.tplinkcloud.com
	uci set cloud_sdk.cloud.validateSvr=n-device-api.tplinkcloud.com
	uci commit cloud_sdk
	restart_flag=1
elif [ $1 = "beta" ];then
	uci set cloud_sdk.cloud.sefDomain=n-deventry-beta.tplinkcloud.com
	uci set cloud_sdk.cloud.defaultSvr=n-devs-beta.tplinkcloud.com
	uci set cloud_sdk.cloud.validateSvr=n-device-api-beta.tplinkcloud.com
	uci commit cloud_sdk
	restart_flag=1
elif [ $1 = "beta2" ];then
	uci set cloud_sdk.cloud.sefDomain=n-aps1-deventry-beta2.tplinkcloud.com
	uci set cloud_sdk.cloud.defaultSvr=n-devs-smb-beta2.tplinkcloud.com
	uci set cloud_sdk.cloud.validateSvr=n-device-api-beta2.tplinkcloud.com
	uci commit cloud_sdk
	restart_flag=1
else
	usage
fi

if [ $restart_flag -ge 1 ];then
	/etc/init.d/cloud_sdk stop
	/etc/init.d/cloud_client stop
	/etc/init.d/cloud_service terminate
	/etc/init.d/cloud_sdk start
	/etc/init.d/cloud_client start
	/etc/init.d/cloud_service start
fi	





