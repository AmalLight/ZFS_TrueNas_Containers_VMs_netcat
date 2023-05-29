#!/bin/bash

# sudo fallocate -l 20G /dev/disk1

sudo fallocate -l 20G /home/kaumi/disk1

# sudo zpool create bigpool disk1

sudo zpool create bigpool /home/kaumi/disk1

zpool list

zpool status -v

sudo zfs create bigpool/data

zfs list

zpool status -v
