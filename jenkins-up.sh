#!/bin/bash

#Read entity names from file
source ../entity-list.sh

# Check docker network exist
if [ -z "$(docker network ls | grep $network_name)" ]; then
  docker network create $network_name
fi

# Check docker volumes exist
if [ -z "$(docker volume ls | grep $vol_jenkins_certs)" ]; then
  docker volume create $vol_jenkins_certs
fi
if [ -z "$(docker volume ls | grep $vol_jenkins_data)" ]; then
  docker volume create $vol_jenkins_data
fi

#Start docker-in-docker for jenkins
if [ -z "$(docker ps -a | grep $con_jenkins_dind)" ]; then
  docker container run --name $con_jenkins_dind --rm --detach \
    --privileged --network $network_name --network-alias docker \
    --env DOCKER_TLS_CERTDIR=/certs \
    --volume $vol_jenkins_certs:/certs/client \
    --volume $vol_jenkins_data:/var/jenkins_home \
    --publish 2376:2376 docker:dind
fi


#Start jenkins container
if [ -z "$(docker ps -a | grep $con_jenkins)" ]; then
  docker container run --name $con_jenkins --rm --detach \
    --network $network_name --env DOCKER_HOST=tcp://docker:2376 \
    --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 \
    --volume $vol_jenkins_data:/var/jenkins_home \
    --volume $vol_jenkins_certs:/certs/client:ro \
    --publish 8080:8080 --publish 50000:50000 jenkinsci/blueocean
fi

if [ ! -f ./jenkins-info ]; then
  echo "The jenkins password is:" > jenkins-info
  docker container exec -it $con_jenkins cat /var/jenkins_home/secrets/initialAdminPassword >> jenkins-info
  echo "jenkins-info file is generated"
fi
