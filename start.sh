#!/bin/bash

DOCKER_COMPOSE_FILE="docker-compose.yml"
PRIVATE_IP=`ifconfig eth1 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}'`

export LGNS_HOST=$PRIVATE_IP
export LGNS_PORT=1712
export HTTP_HOST=127.0.0.1
export HTTP_PORT=8004

docker pull kirilltitov/elegion:quorum_latest

docker-compose -f $DOCKER_COMPOSE_FILE stop service
docker-compose -f $DOCKER_COMPOSE_FILE rm -f service
docker-compose -f $DOCKER_COMPOSE_FILE up -d

echo "Waiting 2 seconds for service to warmup"

sleep 2

if [ -z `docker ps -q --no-trunc | grep $(docker-compose ps -q service)` ]; then
    echo "Service is NOT UP, showing logs"
    docker-compose logs service
else
    echo "Service seems to be healthy"
fi
