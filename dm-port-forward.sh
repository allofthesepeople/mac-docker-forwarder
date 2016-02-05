#!/usr/bin/env bash

# ---------------------------------------------------------
# Action to take
# ---------------------------------------------------------
if [ $# -eq 0 ]
  then
    echo "Eror: Action required (start|stop)"
    exit 1
fi

ACTION=$1
shift


# ---------------------------------------------------------
# The active docker-machine
# ---------------------------------------------------------
ACTIVE_MACHINE="$(docker-machine active)"
if [ $? -ne 0 ]; then
    exit 0
fi

ACTIVE_MACHINE_IP=$(docker-machine ip $ACTIVE_MACHINE)


# ---------------------------------------------------------
# Containers & their ports
# ---------------------------------------------------------
CONTAINERS=$(docker ps | awk '!/CONTAINER ID/' | awk '{print $1}')

MACHINE_PORTS=""

for container in $CONTAINERS
do
    MACHINE_PORTS="$MACHINE_PORTS $(docker port $container | cut -d':' -f 2)"
done


# ---------------------------------------------------------
# Start/Stop
# ---------------------------------------------------------
function forward_machine_ports_start() {
    for port in $MACHINE_PORTS
    do
        echo "forwarding $port"
        ssh -N -f -C -L $port":localhost:"$port \
          -o PasswordAuthentication=no \
          -o IdentitiesOnly=yes \
          -o StrictHostKeyChecking=no \
          -o UserKnownHostsFile=/dev/null \
          -o LogLevel=quiet \
          -o ConnectionAttempts=3 \
          -o ConnectTimeout=10 \
          -o ControlMaster=no \
          -o ControlPath=no \
          docker@$ACTIVE_MACHINE_IP \
          -i ~/.docker/machine/machines/$ACTIVE_MACHINE/id_rsa
    done
}


function forward_machine_ports_stop() {
    echo "$ACTIVE_MACHINE"

    for port in $MACHINE_PORTS
    do
        spec=$port":localhost:"$port
        echo "unforwarding $spec"
        ps aux | grep $spec | grep -v grep | awk '{print $2}' | xargs kill
    done
}


# ---------------------------------------------------------
# And go…
# ---------------------------------------------------------
if [ "$ACTION" = "start" ]
then
    forward_machine_ports_start
fi

if [ "$ACTION" = "stop" ]
then
    forward_machine_ports_stop
fi
