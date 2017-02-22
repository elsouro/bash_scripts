#!/bin/bash

start=`date +%s%3N`
sqsh -S sitc-mssql -U sa -P qia8x8 -D sitc -C 'select count(*) from users' 2>&1 1>/dev/null
end=`date +%s%3N`
runtime=$((end-start))

#echo $runtime
zabbix_sender -z 10.68.1.83 -s 'sd-srv-opm03' -k sql-check -o $runtime
