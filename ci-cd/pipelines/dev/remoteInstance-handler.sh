#!/bin/bash

# Connect to remote dotCMS Application server Instance

set -x #echo on


handler=$1
appServerPemKey=$2

echo "Handler : $handler"


if [ "$handler" = "deploy" ] 
then

    ssh -i ${appServerPemKey} -o StrictHostKeyChecking=no ${REMOTE_SERVER_INSTANCE_USER}@${REMOTE_SERVER_INSTANCE_IP} GIT_DOWNLOAD_DIR=${GIT_DOWNLOAD_DIR} APP_DIR=${APP_DIR} \
        GIT_REPO_URL=${GIT_REPO_URL} GIT_BRANCH_NAME=${GIT_BRANCH_NAME} APP_CONTAINER_NAME=${APP_CONTAINER_NAME} \
        DOTCMS_GIT_CREDS=${DOTCMS_GIT_CREDS} NFS_CONTAINER_IP=${NFS_CONTAINER_IP} VOLUME_NFS=${VOLUME_NFS} \
        DOTCMS_USERNAME=${DOTCMS_USERNAME} DOTCMS_USERPWD=${DOTCMS_USERPWD} \
        APP_IMAGE_NAME=${APP_IMAGE_NAME} APP_LAUNCH_ENV=${APP_LAUNCH_ENV} CONTAINERS_TO_DEPLOY=${CONTAINERS_TO_DEPLOY} \
        'sh -s' < ${CICD_SCRIPT_LOCATION}/dotcms-updater.sh


elif [ "$handler" = "postdeploy" ]
then

    echo "Access Web Application [User Portal] : http://${REMOTE_SERVER_INSTANCE_IP}:${DOTCMS_APP_PORT}"
    echo "Access Web Application [Admin Portal] : http://${REMOTE_SERVER_INSTANCE_IP}:${DOTCMS_APP_PORT}/admin"

else
    echo "Invalid Handler passed to script."
fi