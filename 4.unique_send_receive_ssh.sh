#!/bin/bash

final_server=$1
execute=$2
pass=''

echo ''
echo " final ip for server: $final_server "
echo ''

if (( ${#@} < 3 )) ; then read -p 'server pass: ' -s pass && echo '' ; else pass=$3 ; fi
                     

ssh admin@192.168.56.$final_server -t "echo $pass | sudo -S echo '' ; \
                                       \
                                       sudo chown admin:admin -R /mnt/bigpool_recv ; \
                                            chmod 755            /mnt/bigpool_recv ; \
                                       \
                                       sudo /sbin/zfs destroy -r bigpool_recv/free_space/snap ; echo 'auto unmount and delete' ; \
                                       sudo /sbin/zfs destroy -r bigpool_recv/free_space/data ; echo 'auto unmount and delete' ; \
                                       \
                                       /sbin/zfs create bigpool_recv/free_space/snap ; echo 'auto mount disabled for no-root' ; \
                                       /sbin/zfs create bigpool_recv/free_space/data ; echo 'auto mount disabled for no-root' ; \
                                       \
                                       sudo /sbin/zfs allow -u admin diff     bigpool_recv ; \
                                       sudo /sbin/zfs allow -u admin mount    bigpool_recv ; \
                                       sudo /sbin/zfs allow -u admin receive  bigpool_recv ; \
                                       sudo /sbin/zfs allow -u admin create   bigpool_recv ; \
                                       sudo /sbin/zfs allow -u admin snapshot bigpool_recv ; \
                                       sudo /sbin/zfs allow -u admin rename   bigpool_recv ; \
                                       sudo /sbin/zfs allow -u admin share    bigpool_recv ; \
                                       sudo /sbin/zfs allow -u admin destroy  bigpool_recv ; \
                                       sudo /sbin/zfs allow                   bigpool_recv "

# ssh admin@192.168.56.$final_server /sbin/zfs destroy -r bigpool_recv/free_space/snap
# ssh admin@192.168.56.$final_server /sbin/zfs destroy -r bigpool_recv/free_space/data
# ssh admin@192.168.56.$final_server /sbin/zfs create     bigpool_recv/free_space/snap
# ssh admin@192.168.56.$final_server /sbin/zfs create     bigpool_recv/free_space/data
# ssh admin@192.168.56.$final_server /sbin/zfs destroy -r bigpool_recv/free_space/snap@today
# ssh admin@192.168.56.$final_server /sbin/zfs destroy -r bigpool_recv/free_space/data@today

if [[ $execute == 'true' ]] ;
then
     # auto unmount and auto delete the folder
     sudo zfs send bigpool_mib/data@today | ssh admin@192.168.56.$final_server /sbin/zfs receive -F  bigpool_recv/free_space/snap
     sudo zfs send bigpool_mib/data@today | ssh admin@192.168.56.$final_server /sbin/zfs receive -Fd bigpool_recv/free_space

     ssh admin@192.168.56.$final_server -t "echo $pass | sudo -S echo second ; \
                                            \
                                            sudo /sbin/zfs mount bigpool_recv/free_space/snap ; \
                                            sudo /sbin/zfs mount bigpool_recv/free_space/data ; "

     ssh admin@192.168.56.$final_server /sbin/zfs list -t snapshot

     ssh admin@192.168.56.$final_server ls -all /mnt/bigpool_recv/free_space
fi

ssh admin@192.168.56.$final_server ls -all /mnt/bigpool_recv
ssh admin@192.168.56.$final_server ls -all /mnt

ssh admin@192.168.56.$final_server /sbin/zpool list
ssh admin@192.168.56.$final_server /sbin/zpool status -v
ssh admin@192.168.56.$final_server /sbin/zfs   list

# ( for receive )
# unmount is permitted because auto mount was disabled for no-root, mount requires root's privileges => no auto mount if it was disabled
