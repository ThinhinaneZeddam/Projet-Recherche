#!/bin/sh

which disable_hw_wtd && disable_hw_wtd

for prog in $@
do
	count=0
	echo checking $prog
	while ps|grep -w $prog|grep -v make_sure_prog_exit.sh|grep -v grep
	do
		echo count=$count
		count=$((count+1))
		if [ $((count%60)) -eq 0 ]; then
			reboot
		elif [ $((count%20)) -eq 0 ]; then
			killall -9 $prog
		elif [ $((count%10)) -eq 0 ]; then
			killall $prog
		fi
		sleep 1
	done
done
