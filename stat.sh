#!/bin/bash
LOGFILE=/root/asterisk.full

time_diff()
{
NUMBER=$1
FIRST_LINE=$2
SECOND_LINE=$3
if [[ -n $NUMBER ]] && [[ -n $SECOND_LINE ]]; then
	echo '---'
	#echo 'Verbose: '$NUMBER
	#echo 'Verbose: '$FIRST_LINE
	#echo 'Verbose: '$SECOND_LINE
	START=`echo $FIRST_LINE |cut -f2 -d' ' |cut -c1-12`
	STOP=`echo $SECOND_LINE |cut -f2 -d' ' |cut -c1-12`
	COMPARE=$(($(date -d $STOP +%s) - $(date -d $START +%s)))
	[[ $COMPARE -gt 0 ]] && echo $COMPARE || echo 'ERROR'
	echo '---'
fi
}

full_path()
{
grep '== Handling incoming call' $LOGFILE |while read LINE;
do
	#awk - костыль
	#NUMBER=`echo $LINE |cut -f10 -d' ' |awk '/[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]/{print $0}'`
	NUMBER=9415400184
	if [[ $NUMBER =~ ^[0-9]{10}$ ]]; then
		#echo 'Verbose: NUMBER='$NUMBER
		ANSWERED=`egrep 'app_verbose\.c.*answered caller '$NUMBER' on queue GROUP_VEHICLE_1' $LOGFILE |head -n1`
		if [[ -n $ANSWERED ]]; then 
			echo 'Verbose: LINE='$LINE
			echo 'Verbose: ANSWERED='$ANSWERED 
			time_diff "${NUMBER}" "${LINE}" "${ANSWERED}"
			TRANSFER_DISP=`egrep 'app_verbose\.c.*Transfer number '$NUMBER' to Dispatchers queue' $LOGFILE |head -n1`
			if [[ -n $TRANSFER_DISP ]]; then 
				echo 'Verbose: TRANSFER_DISP='$TRANSFER_DISP 
				time_diff "${NUMBER}" "${ANSWERED}" "${TRANSFER_DISP}"
				
			fi
		fi
	fi
done
}


case $1 in
	full_path)
		$1
		;;
	*)
		echo 'error'
		;;
esac

