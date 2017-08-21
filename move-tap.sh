#!/bin/bash
LOGFILE="/ftp/"$0".log"
TAPSRC=$1
TAPDEST="TAP-ALL"
DATE=`/bin/date '+%F %T'`

# mv ./TAP-ALL/* ./TAP-MEGAFON/ && rm -f ./TAP-ALL/* && rm -f ./TAP-MEGAFON.archive/*
movefiles()
{

if [[ ! -e /ftp/$TAPSRC.archive ]]; then
	echo $DATE" - No destination directory /ftp/"$TAPSRC.archive >> $LOGFILE
	exit 1
fi
if [[ ! -e /ftp/$TAPDEST ]]; then
	echo $DATE" - No destination directory /ftp/"$TAPDEST >> $LOGFILE	
	exit 1
fi

FILES=`/bin/find /ftp/$TAPSRC -type f`
if [[ -z $FILES ]]; then
	echo $DATE" - Nothing found in /ftp/"$TAPSRC >> $LOGFILE
fi	
for i in $FILES; do
	DATE=`/bin/date '+%F %T'`
	FILENAME=`/bin/echo $i |/bin/cut -f4 -d'/'`
	echo $DATE "- Found file "$i >> $LOGFILE
	cp -f $i /ftp/$TAPSRC.archive/ > /dev/null 2>&1 && echo $DATE" - Copied "$i" to archive" >> $LOGFILE || echo $DATE" - Archieving failed for "$i >> $LOGFILE
	cp $i /ftp/$TAPDEST/ > /dev/null 2>&1 && echo $DATE" - Copied "$i" to "$TAPDEST >> $LOGFILE || echo $DATE" - Copy failed for "$i >> $LOGFILE
	ls /ftp/$TAPDEST/$FILENAME > /dev/null 2>&1 && (rm -f $i && echo $DATE" - Successfully removed file "$i >> $LOGFILE) || echo $DATE" - Destination file not found, remove cancelled for "$i >> $LOGFILE
done
}

# touch -t 201708021200 ./TAP-MEGAFON.archive/TAPKA03
rotatearchive()
{
find /ftp/*.archive -type f -mtime +7 -exec rm {} \;
}

case "$1" in
	TAP-KTEL|TAP-MEGAFON|TAP-MTS-done|TAP-VK)
		movefiles
		;;
	rotatearchive)
		rotatearchive
		;;
	*)
		exit 1
		;;
esac
