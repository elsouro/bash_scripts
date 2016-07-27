#!/bin/bash
FST=0
while [ $FST -lt 255 ] 
do
        SEC=0
        while [ $SEC -lt 255 ]
        do
                echo '10.'$FST'.'$SEC'. -' `egrep "^10\.$FST\.$SEC\..*" /tmp/sm_upstream_failure_20160726_2100 |wc -l`
                (( SEC++ ))
        done
        (( FST++ ))
done
echo 'done'
