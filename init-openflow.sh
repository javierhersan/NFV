#!/bin/bash

while getopts a:b: flag
do
    case "${flag}" in
        a) h11=${OPTARG};;
        b) h12=${OPTARG};;
    esac
done

deployment_id() {
    echo `osm ns-list | grep $1 | awk '{split($0,a,"|");print a[3]}' | xargs osm vnf-list --ns | grep $2 | awk '{split($0,a,"|");print a[2]}' | xargs osm vnf-show --literal | grep name | grep $2 | awk '{split($0,a,":");print a[2]}' | sed 's/ //g'`
}

if [[ $h11 == "" ]] || [[ $h12 == "" ]]
then
    echo "init-openflow.sh: IPs not defined"
else
    # OpenFlow for renes1
    echo "h11:"$h11
    echo "h12:"$h12
    echo "Iniciando OpenFlow en renes ..."
    OSMACC1=$(deployment_id renes1 "access")
    VACC1="deploy/$OSMACC1"
    if [[ ! $VACC1 =~ "helmchartrepo-accesschart"  ]]; then
        echo ""       
        echo "ERROR: incorrect <access_deployment_id>: $VACC1"
        exit 1
    fi
    ACC_EXEC_1="kubectl exec -n $OSMNS $VACC1 --"
    $ACC_EXEC_1 ./openflow.sh -a $h11 -b $h12 &
fi