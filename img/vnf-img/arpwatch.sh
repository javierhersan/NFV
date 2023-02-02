#!/bin/bash

echo "Verify arpwatch is running"
ps -ef |grep arpwatch

echo "Verify arp table"
arp -a

echo "Verificar tablas .dat: "
etc/init.d/arpwatch stop
sleep 2

echo "brint.dat: "
cat /var/lib/arpwatch/brint.dat

etc/init.d/arpwatch start
etc/init.d/arpwatch status