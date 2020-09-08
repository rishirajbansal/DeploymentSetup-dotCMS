#!/bin/bash

#set -x #echo on

echo 

# 1-> Deploy dotCMS application to AWS Elastic Beanstalk

cd ${APP_DIR}/aws/prod/bin/ebAutomations/dotcms

${AWS_CLI_EXEC_PATH}/aws --version

echo && echo "Calling 'rollbackAppFromEB' to rollback application from AWS Elastic Beanstalk"

./rollbackAppFromEB.sh -m "${DEPLOYMENT_DESC}" ${APP_BUNDLE_NAME} "${PREV_APP_VERSION_NAME}" ${AWS_CLI_EXEC_PATH}

if [ $? -ne 0 ]; then
    echo "Error occued while deploying application, process will be terminated..."
    exit 1
else
    echo "Application deployment to AWS Elastic Benastalk is done."
fi

