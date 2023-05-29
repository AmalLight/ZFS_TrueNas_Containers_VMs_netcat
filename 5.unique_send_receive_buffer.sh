#!/bin/bash

final_server=$1
port=$2

echo ''
echo " final ip for server: $final_server "
echo " port: $port "
echo ''

read -p 'server pass: ' -s pass ; echo ''

sudo echo zero

ssh admin@192.168.56.$final_server -t 'pkill mbuffer'

. 4.unique_send_receive_ssh.sh $final_server 'false' $pass

xfce4-terminal --tab \
\
--command "ssh admin@192.168.56.$final_server -t 'sleep 1 ; \
           \
           nc -v -w 120 -l -p $port | /sbin/zfs receive -v -F bigpool_recv/free_space/data ; \
           \
           echo $pass | sudo -S echo second ; \
           \
           sudo /sbin/zfs mount      bigpool_recv/free_space/data ; \
           sudo /sbin/zfs destroy -r bigpool_recv/free_space/snap ; \
           \
           ls -all /mnt/bigpool_recv/free_space ; \
           /sbin/zfs list -t snapshot           ; \
           \
           tmp='' ; vared -p end -c tmp '" \
\
-T "Run and ready"

sleep 3

# nmap 192.168.56.$final_server

# -4 -s 128k -m 2m

sudo zfs send -v bigpool_mib/data@today | nc -v -w 20 192.168.56.$final_server $port
