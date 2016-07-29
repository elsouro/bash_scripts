#!/bin/bash

#проверка на наличие уже запущенного скрипта
function smwaitfor()
{
  prog=`basename $0`
    waitforpid=`ps -ef |grep -v grep|grep $prog |awk {'print $2'} | wc -l`
      if [  "$waitforpid" -gt 2 ]; then  #почему больше двух?
      exit 0
      fi
}

smwaitfor

#источник параметров
. /backup/Almaty/crontab_backup_script.conf

#коммитим чужие изменения
cd $work_directory; svn commit -m "commiting..."; svn update

#переменные для каждого блока параметров
for ((IP=1; IP <= 63 ; IP++))
do
server_n="SERVER_${IP}"
folders_n="FOLDERS_${IP}"
files_n="FILES_${IP}"
eval server_name='$'$server_n
eval folders_name='$'$folders_n
eval files_name='$'$files_n
#если блок не пустой, продолжаем
if [ $server_name  ]; then

#странная проверка на медленный ssh (?)
(
nc $server_name 22 > /dev/null 2>&1 & <<EOF

EOF
)
sleep 1
while true
  do
  process_pid=`ps -ef |grep -v grep | grep "nc $server_name" | awk {'print $2'}`
  echo $process_pid
  if [ -n "$process_pid" ]
  then
    echo "Failed"
    kill -9 $process_pid > /dev/null 2>&1
    sleep 1
    kill -9 $process_pid > /dev/null 2>&1
    sleep 1
    kill -9 $process_pid > /dev/null 2>&1
    sleep 1
    break
  else
#конец проверки. если netcat висел в процессах, скрипт завершен
#если все ок, открыли цикл
  echo $server_name
#cycle for shared folders
  for folders_shared in $FOLDERS_SHARED
  do
    rsync -avz -R $server_name:$folders_shared ${work_directory}/${server_name}/
    echo $folders
  done
#cycle for individual folders
  for folders in $folders_name
  do
    rsync -avz -R $server_name:$folders ${work_directory}/${server_name}/
    echo $folders
  done
#cicle for shared files
  for files_shared in $FILES_SHARED
  do
    rsync -avz -R $server_name:$files_shared ${work_directory}/${server_name}/
    echo $files
  done
#cicle for individual files
  for files in $files_name
  do
    rsync -avz -R $server_name:$files ${work_directory}/${server_name}/
    echo $files
  done
  break
  fi
  done
  echo "------------------------"
fi
done

#собираем конфиги с сетевого оборудования
MY_SERVERS_FILE=CISCO_IPs.txt
MY_SERVER_LIST="`cat CISCO_IPs.txt  | grep -v '#' | grep -v '^$'`"

num=`echo "$MY_SERVER_LIST" | wc -l`
index=1
#для каждой строки выполняем
while [ "$index" -le "$num" ]
do
    var=`echo "$MY_SERVER_LIST" | sed "$index!d"`
#expect-скрипт с командой слить конфиг
#    ./catalysts_cmds $var
    IP=`expr match "$var" '\([0-9]*.[0-9]*.[0-9]*.[0-9]*\)'`
    mkdir -p /backup/Almaty/work_directory/$IP
    mv -f /tftpboot/* /backup/Almaty/work_directory/$IP
    index=$(($index+1))
done

#коммитим все что собрали в svn
cd $work_directory; for i in `find $work_directory/ -not -path "*/.svn*"`; do svn add $i; done; svn commit -m "add new files or/and folders"; svn update
