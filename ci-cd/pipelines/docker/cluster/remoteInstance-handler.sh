#!/bin/bash

# Connect to remote dotCMS Application server Instance

#set -x #echo on


handler=$1
appServerPemKey=$2

echo "Handler : $handler"


if [ "$handler" = "deploy" ] 
then

    ssh -i ${appServerPemKey} -o StrictHostKeyChecking=no ${REMOTE_SERVER_INSTANCE_USER}@${REMOTE_SERVER_INSTANCE_IP} GIT_DOWNLOAD_DIR=${GIT_DOWNLOAD_DIR} APP_DIR=${APP_DIR} \
        GIT_REPO_URL=${GIT_REPO_URL} GIT_BRANCH_NAME=${GIT_BRANCH_NAME} DOTCMS_GIT_CREDS=${DOTCMS_GIT_CREDS} \
        NFS_CONTAINER_IP=${NFS_CONTAINER_IP} APP_LAUNCH_ENV=${APP_LAUNCH_ENV} CONTAINERS_TO_DEPLOY=${CONTAINERS_TO_DEPLOY} \
        'sh -s' < ${CICD_SCRIPT_LOCATION}/dotcms-updater.sh

elif [ "$handler" = "postdeploy" ]
then

    echo "Access Web Application [Admin Portal] : http://${REMOTE_SERVER_INSTANCE_IP}:${DOTCMS_APP_PORT}/admin"
    
    echo && echo "Please add following lines in /etc/hosts files to make sandbox application work: " && echo
    echo "======================================================" && echo

    echo ${REMOTE_SERVER_INSTANCE_IP} 'test-ext.engagedmd.com'
    echo ${REMOTE_SERVER_INSTANCE_IP} 'sandbox.test-ext.engagedmd.com'
    echo ${REMOTE_SERVER_INSTANCE_IP} 'training.test-ext.engagedmd.com'
    echo
    echo ${REMOTE_SERVER_INSTANCE_IP} 'test.engagedmd.com'
    echo ${REMOTE_SERVER_INSTANCE_IP} 'sandbox.test.engagedmd.com'
    echo ${REMOTE_SERVER_INSTANCE_IP} 'training.test.engagedmd.com'

    echo "======================================================" && echo
    echo

else
    echo "Invalid Handler passed to script."
fi