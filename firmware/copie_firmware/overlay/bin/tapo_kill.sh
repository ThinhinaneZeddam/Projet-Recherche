#!/bin/sh
# Copyright (C) 2006-2011 OpenWrt.org
kill -9 `ps|grep wtd|grep -v grep|awk '{print $1}'` 
#kill -9 `ps|grep cloud|grep -v grep|awk '{print $1}'`                                  
                                                
must_kill="cet vda rtspd nvid motord storage_manager cloud-client cloud-service cloud-brd dsd relayd p2pd"                                    
for file in $must_kill;do                                              
        #re=$(ps | grep "$file" | grep -v "grep")
        #id=${re%%r*}
        #kill -9 $id
		echo kill $file
		kill -9 `ps|grep "$file"|grep -v grep|awk '{print $1}'`
done

which disable_hw_wtd && disable_hw_wtd

echo 3 > /proc/sys/vm/drop_caches

