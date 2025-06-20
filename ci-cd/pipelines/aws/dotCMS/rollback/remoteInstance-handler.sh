#!/bin/bash

# Connect to remote server Instance

set -x #echo on


handler=$1
appServerPemKey=$2
deploymentDescription=$3
appBundleName=$4
preAppVersionName=$5

echo "Handler : $handler"


if [ "$handler" = "rollback" ] 
then

    ssh -i ${appServerPemKey} -o StrictHostKeyChecking=no ${REMOTE_SERVER_INSTANCE_USER}@${REMOTE_SERVER_INSTANCE_IP} GIT_DOWNLOAD_DIR=${GIT_DOWNLOAD_DIR} APP_DIR=${APP_DIR} \
        GIT_REPO_URL=${GIT_REPO_URL} GIT_BRANCH_NAME=${GIT_BRANCH_NAME} DOTCMS_GIT_CREDS=${DOTCMS_GIT_CREDS} \
        AWS_CLI_EXEC_PATH=${AWS_CLI_EXEC_PATH} AWS_PROFILE_NAME=${AWS_PROFILE_NAME} S3_BUCKET_NAME_APP=${S3_BUCKET_NAME_APP} \
        REGION=${REGION} ENV=${ENV} \
        DEPLOYMENT_DESC="'${deploymentDescription}'"  APP_BUNDLE_NAME=${appBundleName} PREV_APP_VERSION_NAME="'${preAppVersionName}'" \
        'sh -s' < ${CICD_SCRIPT_LOCATION}/rollback-handler.sh

else
    echo "Invalid Handler passed to script."
fi