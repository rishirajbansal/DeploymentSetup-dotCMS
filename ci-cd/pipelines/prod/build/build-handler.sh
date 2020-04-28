#!/bin/bash

set -x #echo on




# 4-> Create and Upload - dotCMS App Bundle & EB Deployment Bundle to S3 bucket
cd ${APP_DIR}/aws/prod/bin/ebAutomations

${AWS_CLI_EXEC_PATH}/aws --version

echo "Calling 'createUploadAppBundle' to create and upload app bundle to S3"

./createUploadAppBundle.sh ${AWS_PROFILE_NAME} ${S3_BUCKET_NAME_APP} ${AWS_CLI_EXEC_PATH}

echo "Calling 'createUploadEBDeployBundle' to create and upload EB Deployment Bundle to S3"

./createUploadEBDeployBundle.sh ${AWS_PROFILE_NAME} ${S3_BUCKET_NAME_APP} ${AWS_CLI_EXEC_PATH}

echo "Creating and Uploading of App Bundle and EB Deployment is done."