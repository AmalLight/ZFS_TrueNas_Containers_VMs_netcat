#!/bin/bash

zfs list -t snapshot

echo ''

sudo zfs destroy -r bigpool/data

echo ''
echo 'DESTROYED SNAP EXCEL'
echo ''

zfs list -t snapshot

echo ''

sudo zfs send -v bigpool_snapshot/data@excel | sudo zfs receive -v -d bigpool

echo ''
echo 'SENT SNAP TO EXCEL'
echo ''

zfs list -t snapshot

echo ''

sudo zfs rollback -r bigpool/data@excel

echo ''

zpool list
zpool status -v
zfs   list
