#!/bin/bash

export NSID1=$(osm ns-create --ns_name renes1 --nsd_name renes --vim_account dummy_vim)
echo "NSID1"$NSID1

sleep 20

#watch osm ns-list

