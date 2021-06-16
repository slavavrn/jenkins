#!/bin/bash

#Read entity names from file
source ../entity-list.sh

#Stop jenkins container and immediaty auto delete it
if [ -n "$(docker ps -a | grep $con_jenkins)" ]; then
  docker container stop $con_jenkins
fi

if [ -n "$(docker ps -a | grep $con_jenkins_dind)" ]; then
  docker container stop $con_jenkins_dind
fi

# Check docker network exist and delete it
if [ -n "$(docker network ls | grep $network_name)" ]; then
  docker network rm $network_name
fi

# Check docker volumes exist and delete it
if [ -n "$(docker volume ls | grep $vol_jenkins_certs)" ]; then
  docker volume rm $vol_jenkins_certs
fi
if [ -n "$(docker volume ls | grep $vol_jenkins_data)" ]; then
  docker volume rm $vol_jenkins_data
fi

rm jenkins-info