#!/bin/bash

sudo fallocate -l 12G /home/kaumi/disk2

sudo zpool create bigpool_snapshot /home/kaumi/disk2

zpool list

zpool status -v

zfs list
