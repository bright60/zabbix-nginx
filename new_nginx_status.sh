#!/bin/bash
# Script to fetch nginx statuses for tribily monitoring systems
# Author: yuchao@ymt360.com

# Set Variables
url="http://127.0.0.1/nginx_status"
hostname=`hostname`

# Functions to return nginx stats

function ping {
    /bin/pidof nginx | wc -l

    status=`curl $url 2>/dev/null`
    declare -A dict
    dict[Active]=`echo "$status"|grep 'Active' | awk '{print $NF}'`
    dict[Reading]=`echo "$status"|grep 'Reading' | awk '{print $2}'`
    dict[Writing]=`echo "$status"|grep 'Writing' | awk '{print $4}'`
    dict[Waiting]=`echo "$status"|grep 'Waiting' | awk '{print $6}'`
    dict[accepts]=`echo "$status"| awk NR==3 | awk '{print $1}'`
    dict[handled]=`echo "$status"| awk NR==3 | awk '{print $2}'`
    dict[requests]=`echo "$status"| awk NR==3 | awk '{print $3}'`
    for key in $(echo ${!dict[*]})
    do
        #echo "$key : ${dict[$key]}"
        /usr/bin/zabbix_sender -vv -s ${hostname} -o "${dict[$key]}" -k "${key}" -z s-zabbix-proxy-m.ymt.io -p 10051 >/dev/null
    done
}
function status_500 {
    tail -n 10000 /data/logs/nginx/*.log |awk '{if($9 >= 500){print $9}}'|wc -l
}
# Run the requested function
$1
