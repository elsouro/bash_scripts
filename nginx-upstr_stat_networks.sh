#!/bin/bash
#Разбирает upstream.log по кол-ву запросов из подсетей 10.*

FST=0
UPSTR_FILE="/tmp/sm_upstream_failure_20160726_2100"

if [ $FST -ne 0 ]; then
SEC=0
egrep "^10\.$FST\..*" $UPSTR_FILE > $UPSTR_FILE.network-10.$FST.x.x.tmp
while [ $SEC -lt 255 ]
        do
        echo '10.'$FST'.'$SEC'.* -' `egrep "^10\.$FST\.$SEC\..*" $UPSTR_FILE.network-10.$FST.x.x.tmp |wc -l`
        (( SEC++ ))
        done

else
while [ $FST -lt 255 ] 
        do
        egrep "^10\.$FST\..*" $UPSTR_FILE > $UPSTR_FILE.network-10.$FST.x.x.tmp
        WC=`cat $UPSTR_FILE.network-10.$FST.x.x.tmp |wc -l`
        if [ $WC -gt 0 ] ; then
        echo '10.'$FST'.*.* -   '$WC
        fi
        (( FST++ ))
        done
fi
rm -f $UPSTR_FILE.network-10.*.tmp
echo 'done'
