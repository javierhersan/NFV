OSMCPE1=$(deployment_id renes1 "cpe")
VCPE1="deploy/$OSMACC1"
if [[ ! $VCPE1 =~ "helmchartrepo-cpechart"  ]]; then
    echo ""       
    echo "ERROR: incorrect <access_deployment_id>: $VCPE1"
    exit 1
fi
CPE_EXEC_1="kubectl exec -n $OSMNS $VCPE1 --"
$CPE_EXEC_1 ./arpwatch_start.sh # Si peta no lo hacemos