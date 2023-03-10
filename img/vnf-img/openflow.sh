#!/bin/bash

while getopts a:b: flag
do
    case "${flag}" in
        a) h11=${OPTARG};;
        b) h12=${OPTARG};;
    esac
done

if [[ $h11 == "" ]] || [[ $h12 == "" ]]
then
    echo "openflow.sh: IPs not defined"
else
    # Instalar dependencias necesarias
    echo "h11:"$h11
    echo "h12:"$h12
    echo "Instalando dependencias ..."
    cd ryu/
    pip install .
    cd ..

    # Definir versiones OpenFlow
    echo "Definiendo version OpenFlow 1.0, 1.1, 1.2, 1.3 ..."
    ovs-vsctl set Bridge brint protocols=OpenFlow10,OpenFlow11,OpenFlow12,OpenFlow13

    # Definir el puerto del manager y controlador de OpenFlow:
    echo "Definiendo propiedades del controller ..."
    ovs-vsctl set bridge brint other-config:datapath-id=0000000000000001
    ovs-vsctl set-manager ptcp:6632
    ovs-vsctl set-controller brint tcp:127.0.0.1:6633

    # Crear qos_simple_switch_13.py
    echo "Creando qos_simple_switch_13.py ..."
    sed '/OFPFlowMod(/,/)/s/)/, table_id=1)/' ryu/ryu/app/simple_switch_13.py > ryu/ryu/app/qos_simple_switch_13.py

    # Instalar dependencias
    echo "Instalando dependencias ..."
    cd ryu/; python3 ./setup.py install
    cd ..

    # Para ejecutar la aplicacion Ryu:
    echo "Ejecutando aplicacion Ryu qos_simple_switch_13.py ..."
    ryu-manager ryu/ryu/app/rest_qos.py ryu/ryu/app/qos_simple_switch_13.py ryu/ryu/app/rest_conf_switch.py & > ryulogs.log

    # Terminates the program (like Ctrl+C)
    PID=$!
    sleep 5
    kill -INT $PID

    # KNF access -> brgX : 12 Mbps bajada
    # brgX -> KNF access : 6 Mbps subida
    # Definir la ruta del manager
    curl -X PUT -d '"tcp:127.0.0.1:6632"' http://localhost:8080/v1.0/conf/switches/0000000000000001/ovsdb_addr
    sleep 2

    # ----------------------------------------------------------------------------------------------------------
    # Create QoS Downlink Queue 
    # Link max: 12 Mbps 
    # Queue 0 - h11 : min 8 Mbps
    # Queue 1 - h12 : max 4 Mbps
    curl -X POST -d '{"port_name": "vxlanacc", "type": "linux-htb", "max_rate": "12000000", "queues": [{"min_rate": "8000000"}, {"max_rate": "4000000"}]}' http://localhost:8080/qos/queue/0000000000000001
    # Which traffic goes to each queue 
    curl -X POST -d '{"match": {"nw_dst": "'$h11'"}, "actions":{"queue": "0"}}' http://localhost:8080/qos/rules/0000000000000001
    curl -X POST -d '{"match": {"nw_dst": "'$h12'"}, "actions":{"queue": "1"}}' http://localhost:8080/qos/rules/0000000000000001
    
    # ----------------------------------------------------------------------------------------------------------
    # Create QoS Uplink Queue 
    # Link max: 6 Mbps 
    # Queue 0 - h11 : min 4 Mbps
    # Queue 1 - h12 : max 2 Mbps
    $ACC_EXEC_1 curl -X POST -d '{"port_name": "vxlanint", "type": "linux-htb", "max_rate": "6000000", "queues": [{"min_rate": "4000000"}, {"max_rate": "2000000"}]}' http://localhost:8080/qos/queue/0000000000000001
    # Which traffic goes to each queue 
    # MAC h11: 02:fd:00:04:00:01
    # MAC h12: 02:fd:00:04:01:01
    $ACC_EXEC_1 curl -X POST -d '{"match": {"dl_src": "02:fd:00:04:00:01", "dl_type": "IPv4"}, "actions":{"queue": "0"}}' http://localhost:8080/qos/rules/0000000000000001
    $ACC_EXEC_1 curl -X POST -d '{"match": {"dl_src": "02:fd:00:04:01:01", "dl_type": "IPv4"}, "actions":{"queue": "1"}}' http://localhost:8080/qos/rules/0000000000000001



fi
