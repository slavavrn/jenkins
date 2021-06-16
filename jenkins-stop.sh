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
