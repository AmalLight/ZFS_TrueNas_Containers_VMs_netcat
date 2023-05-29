#!/bin/bash

sudo zfs destroy -r bigpool_snapshot/data

echo ''
echo 'DESTROYED OLD SNAP SHOT'
echo ''

sudo zfs snapshot  bigpool/data@excel

echo ''
echo 'CREATED NEW SNAP'
echo ''

zfs list -t snapshot

echo ''

sudo zfs send -v bigpool/data@excel | sudo zfs receive -v -d bigpool_snapshot

echo ''
echo 'SENT SNAP'
echo ''

zfs list -t snapshot

echo ''

sudo zfs destroy -r bigpool/data@excel

echo ''
echo 'DESTROYED OLD SNAP POOL'
echo ''

zfs list -t snapshot

echo ''

zpool list
zpool status -v
zfs   list

# clone can be used only inside the same pool
