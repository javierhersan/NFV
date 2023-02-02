#!/bin/bash

echo deb http://archive.ubuntu.com/ubuntu trusty main universe restricted multiverse >> /etc/apt/sources.list
apt-get update
apt-get install -y sysv-rc-conf
sysv-rc-conf --level 35 arpwatch on
etc/init.d/arpwatch start
etc/init.d/arpwatch status