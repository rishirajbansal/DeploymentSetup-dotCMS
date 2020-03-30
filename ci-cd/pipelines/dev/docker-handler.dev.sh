#!/bin/bash

# Docker environment cleanup Script

set -x #echo on

handler=$1

echo "Docker handler : $handler"

if [ "$handler" = "cleanup" ] 
then

    # Stop the containers:

    # docker container stop ${DB_CONTAINER_NAME}
    # echo "${DB_CONTAINER_NAME} Stopped."
    # docker container stop ${NFS_CONTAINER_NAME}
    # echo "${NFS_CONTAINER_NAME} Stopped."
    docker container stop ${APP_CONTAINER_NAME}
    echo "${APP_CONTAINER_NAME} Stopped."
        
    # Delete preexisted containers:

    # docker container rm --force ${DB_CONTAINER_NAME}
    # echo "${DB_CONTAINER_NAME} Removed."
    # docker container rm --force ${NFS_CONTAINER_NAME}
    # echo "${NFS_CONTAINER_NAME} Removed."
    docker container rm --force ${APP_CONTAINER_NAME}
    echo "${APP_CONTAINER_NAME} Removed."

    # Bring compose down:

    cd ${WORKSPACE}/dotCMS
    docker-compose --log-level ${DOCKER_LOG_LEVEL} down 

    # cd ${WORKSPACE}/nfs
    # docker-compose --log-level ${DOCKER_LOG_LEVEL} down 

    # cd ${WORKSPACE}/postgres
    # docker-compose --log-level ${DOCKER_LOG_LEVEL} down 

    # Remove unused images
    docker rmi $(docker images -f 'dangling=true' -q) || true

elif [ "$handler" = "up" ]
then
    # cd ${WORKSPACE}/postgres
    # docker-compose --log-level ${DOCKER_LOG_LEVEL} up --build -d

    # cd ${WORKSPACE}/nfs
    # docker-compose --log-level ${DOCKER_LOG_LEVEL} up --build -d

    cd ${WORKSPACE}/dotCMS
    docker-compose --log-level ${DOCKER_LOG_LEVEL} up --build -d

elif [ "$handler" = "postdeploy" ]
then
    db_ip=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${DB_CONTAINER_NAME})
    nfs_ip=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${NFS_CONTAINER_NAME})
    app_ip=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${APP_CONTAINER_NAME})
    db_port=$(docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}}{{(index $conf 0).HostPort}} {{end}}' ${DB_CONTAINER_NAME})
    app_port=$(docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}}{{(index $conf 0).HostPort}} {{end}}' ${APP_CONTAINER_NAME})

    echo "Access Application : http://$app_ip:$app_port"
    echo "Access Database : http://$db_ip:$db_port"

    echo "Access Application logs at: ${WORKSPACE}/dotserver/tomcat/logs"

else
    echo "Invalid Docker Handler passed to script."
fi