#!/bin/bash

DOCKER_COMPOSE_FILE="docker/docker-compose.yaml"
PRIVATE_IP=`ifconfig eth1 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}'`

export LGNS_HOST=$PRIVATE_IP
export LGNS_PORT=1712
export HTTP_HOST=127.0.0.1
export HTTP_PORT=8081

docker pull kirilltitov/elegion:quorum_latest

docker-compose -f $DOCKER_COMPOSE_FILE stop quorum
docker-compose -f $DOCKER_COMPOSE_FILE rm -f quorum
docker-compose -f $DOCKER_COMPOSE_FILE up -d
