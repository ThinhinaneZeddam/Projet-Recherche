#!/bin/sh
# Copyright(c) 2009-2020 Shenzhen TP-LINK Technologies Co.Ltd.
fileName="dsdSendCmd.sh"
usage()
{
        echo -e "Brief: execute dsd command file\n"
        echo -e "Usage: \"$0 -[option] [cmd_file]\" or \"$0 -[option]\""
        echo -e "\t-[option] must be the following:"
        echo -e "\t    -s:\t[cmd_file] is context file"
        echo -e "\t    -j:\t[cmd_file] is json file"
        echo -e "\t    -t:\t[cmd_file] is string, space in string is NOT allowed."
        echo -e "\t    -h:\thelp"
        echo -e "\n"
        echo -e "\t-[cmd_file] when -[option] is \"-t\", [cmd_file] must be specified."
        echo -e "\t            when -[option] is \"-s\" or \"-j\", if [cmd_file] exists. [cmd_file] will be called first,"
        echo -e "\t            otherwise default \"command.json\" will be called from the default path \"/tmp\","
        echo -e "\t            if default \"command.json\" does not exist, then create a blank one"
        exit 0
}

if [ -z $1 ] || [ $1 = "-h" ] || [ $# -lt 1 ] || [ $# -gt 2 ]; then
        usage
fi

if [ -n "$2" ]; then
        /usr/bin/dsd_exec $1 $2
elif [ -r /tmp/command.json ]; then
        /usr/bin/dsd_exec $1 /tmp/command.json
else
        touch /tmp/command.json
        echo -e "[${fileName}] /tmp/command.json not exist, create a blank one."
        echo -e "[${fileName}] attention to filling in the command.json!"
fi

