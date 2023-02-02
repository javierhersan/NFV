#!/bin/bash

AUX=$(osm k8scluster-list | grep -o -P '.{0,0}microk8s-cluster.{0,39}')
export KID=${AUX:19:42}
echo "KID:"$KID

CMD=$(osm k8scluster-show --literal $KID | grep -A1 projects)
export OSMNS=${CMD:24:37}
echo "OSMNS:"$OSMNS

osm repo-add helmchartrepo https://javierhersan.github.io/NFV --type helm-chart --description "NFV"

cd ~/shared/NFV/pck
# VNF Package
osm nfpkg-create accessknf_vnfd.tar.gz
osm nfpkg-create cpeknf_vnfd.tar.gz
# NS Package
osm nspkg-create renes_ns.tar.gz