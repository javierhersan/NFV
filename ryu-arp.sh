#!/bin/bash

while getopts a:b:c:d: flag
do
    case "${flag}" in
        h11) h11=${OPTARG};;
        h12) h12=${OPTARG};;
        #c) h21=${OPTARG};;
        #d) h22=${OPTARG};;
    esac
done

export OSMNS  # needs to be defined in calling shell

# service instance name
export SINAME="renes1"
# 
export KUBECTL="kubectl"

deployment_id() {
    echo `osm ns-list | grep $1 | awk '{split($0,a,"|");print a[3]}' | xargs osm vnf-list --ns | grep $2 | awk '{split($0,a,"|");print a[2]}' | xargs osm vnf-show --literal | grep name | grep $2 | awk '{split($0,a,":");print a[2]}' | sed 's/ //g'`
}

# Obtener deployment ids de las vnfs
echo "## 0. Obtener deployment ids de las vnfs"
OSMACC=$(deployment_id $SINAME "access")
OSMCPE=$(deployment_id $SINAME "cpe")
echo $OSMACC
echo $OSMCPE

export VACC="deploy/$OSMACC"
export VCPE="deploy/$OSMCPE"

ACC_EXEC="$KUBECTL exec -n $OSMNS $VACC --"
CPE_EXEC="$KUBECTL exec -n $OSMNS $VCPE --"

## 7. En VNF:cpe activar arpwatch
echo "## 7. En VNF:cpe activar arpwatch"
# $CPE_EXEC /etc/init.d/arpwatch start
# $CPE_EXEC /etc/init.d/arpwatch stop

## 8. En VNF:acc activar ryu
echo "## 8. En VNF:acc activar ryu"
$ACC_EXEC ovs-vsctl set bridge brint protocols=OpenFlow10,OpenFlow11,OpenFlow12,OpenFlow13
$ACC_EXEC ovs-vsctl set-fail-mode brint secure
$ACC_EXEC ovs-vsctl set bridge brint other-config:datapath-id=0000000000000001
$ACC_EXEC ovs-vsctl set-manager ptcp:6632
$ACC_EXEC ovs-vsctl set-controller brint tcp:127.0.0.1:6633
$ACC_EXEC ryu-manager ryu.app.rest_qos ryu.app.rest_conf_switch ./ryu/qos_simple_switch_13.py
# Manager 
$ACC_EXEC curl -X PUT -d '"tcp:127.0.0.1:6632"' http://localhost:8080/v1.0/conf/switches/0000000000000001/ovsdb_addr
# Cola 0: hX1 | min 8 Mbps
# Cola 1: hX2 | max 4 Mbps
$ACC_EXEC curl -X POST -d '{"port_name": "vxlanacc", "type": "linux-htb", "max_rate": "12000000", "queues": [{"min_rate": "8000000"}, {"max_rate": "4000000"}]}' http://localhost:8080/qos/queue/0000000000000001
# Definir a que cola pertenece cada tráfico
$ACC_EXEC curl -X POST -d '{"match": {"nw_dst": "'$h11'"}, "actions":{"queue": "0"}}' http://localhost:8080/qos/rules/0000000000000001
$ACC_EXEC curl -X POST -d '{"match": {"nw_dst": "'$h12'"}, "actions":{"queue": "1"}}' http://localhost:8080/qos/rules/0000000000000001
