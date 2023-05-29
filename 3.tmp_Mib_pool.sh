#!/bin/bash

sudo fallocate -l 100M /dev/disk3

sudo zpool create bigpool_mib disk3

zpool list

zpool status -v

sudo zfs create bigpool_mib/data

zfs list

zpool status -v

sudo zfs snapshot bigpool_mib/data@today

zfs list -t snapshot
