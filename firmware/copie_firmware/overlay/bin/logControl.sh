#!/bin/sh
# Copyright (C) 2006-2011 OpenWrt.org
                                 
pNone="\033[0m"
pForwardRed="\033[40;31m" 
pForwardBlue="\033[47;34m" 
pForwardGreen="\033[40;32m"  
pForwardPurple="\033[40;35m"                                     
touch_log="cet dn_switch region cloudsdk cloudclient dsd relayd p2pd rtspd traversal_common"
ubus_log="vda cloudservice"
touch_flag=0
ubus_flag=0
usage()
{
		on="on"
		off="off"
		force="force"
        echo -e "$pForwardGreen Usage: $0 [moduleName] [switch] [force]$pNone"

        echo -e "\t[moduleName] must be in the modules below:"
        echo -e "\t\ttouch_log:\t[$pForwardPurple$touch_log$pNone]"
        echo -e "\t\tubus_log:\t[$pForwardPurple$ubus_log$pNone]"
		echo 
        echo -e "\t[force] equal [$pForwardPurple$force$pNone]:"
        echo -e "\t\t[$pForwardPurple$force$pNone] been set: touch|rm /tmp/unknowModules.log"
		echo
        echo -e "\t[switch] could be [$pForwardPurple$on$pNone or $pForwardPurple$off$pNone]:"
        echo -e "\t\t$pForwardPurple$on$pNone means open debug log"
        echo -e "\t\t$pForwardPurple$off$pNone means close debug log"

        echo -e "$pForwardGreen Example: $0 cloudsdk on $pNone"
        echo -e "$pForwardGreen Example: $0 vda off $pNone"
        echo -e "$pForwardGreen Example: $0 ualarm_delivery on force $pNone"
        exit 0
}

ubus_call_log()
{
	case $1 in
		vda)
			if [ $2 -eq 1 ];then
				#echo 'ubus call vda set_dbg_level {"dbg_level":1}'
				ubus call vda set_dbg_level '{"dbg_level":1}'
			else
				#echo 'ubus call vda set_dbg_level {"dbg_level":5}'
				ubus call vda set_dbg_level '{"dbg_level":5}'
			fi
			;;
		cloudservice)
			if [ $2 -eq 1 ];then
				#echo 'ubus call msg_push msg_push_set_debug_mode {"debug_mode":1}'
				ubus call msg_push msg_push_set_debug_mode '{"debug_mode":1}'
			else
				#echo 'ubus call msg_push msg_push_set_debug_mode {"debug_mode":0}'
				ubus call msg_push msg_push_set_debug_mode '{"debug_mode":0}'
			fi
			;;
		*)
			echo '$pForwardRed $1 is not in [$ubus_log] $p $pNone'
			;;
	esac

}

if [ -z $1 ] || [ $1 = "-h" ] || [ $# -lt 2 ];then
	usage
fi 
                                
for modules in $touch_log;do                                              
        if [ $modules = $1 ];then
        	touch_flag=1
        	break
        fi
done

for modules in $ubus_log;do                                              
        if [ $modules = $1 ];then
        	ubus_flag=1
        	break
        fi
done

if [ $touch_flag -ne 1 ] && [ $ubus_flag -ne 1 ];then
	echo -e "$pForwardRed $1 not in [$touch_log $ubus_log] $pNone"
	if [ -z $3 ] || [ $3 != "force" ];then
		usage
	else
		touch_flag=1
		if [ $2 = "on" ];then
			echo -e "$pForwardRed $3 touch /tmp/$1.log $pNone"
		else
			echo -e "$pForwardRed $3 rm /tmp/$1.log $pNone"
		fi
	fi
fi

if [ $2 = "on" ];then
	log_on=1
	if [ $touch_flag -eq 1 ];then
		#echo -e "touch /tmp/$1.log"
		touch /tmp/$1.log
	else
		ubus_call_log $1 $log_on
	fi
else
	log_on=0
	if [ $touch_flag -eq 1 ];then
		#echo -e "rm /tmp/$1.log"
		rm /tmp/$1.log
	else
		ubus_call_log $1 $log_on
	fi
fi


