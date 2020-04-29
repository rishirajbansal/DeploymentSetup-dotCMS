#!/bin/bash

set -x #echo on

cd ${GIT_DOWNLOAD_DIR}

mkdir -p dotCMS
cd dotCMS

# 1-> Pull latest code from GitHub

echo "Fetching latest code from GitHub..."

export GIT_TRACE_PACKET=1
export GIT_TRACE=1
export GIT_CURL_VERBOSE=1

GIT_REPO_URL_1="https://${DOTCMS_GIT_CREDS}"
GIT_REPO_URL_2="@${GIT_REPO_URL}"
GIT_REPO_URL_AUTH=${GIT_REPO_URL_1}${GIT_REPO_URL_2}

git init

git rev-parse --is-inside-work-tree

# git config --global --unset http.proxy 
# git config --global --unset https.proxy

git config remote.origin.url ${GIT_REPO_URL_AUTH} 
git config --global http.postBuffer 1048576000

git pull origin ${GIT_BRANCH_NAME}

echo "Git code saved in : ${GIT_DOWNLOAD_DIR}"


# 2-> Zip git folder
if [ -f ${GIT_DOWNLOAD_DIR}/dotCMS.zip ]
then
    rm ${GIT_DOWNLOAD_DIR}/dotCMS.zip
fi  

echo "Compressing dotCMS Artifcats (only AWS Specific) in zip..."
cd ${GIT_DOWNLOAD_DIR}/dotCMS
zip -r -q ${GIT_DOWNLOAD_DIR}/dotCMS.zip aws -x '*.git*'
echo "Compression of dotCMS Artifcats (only AWS Specific) in zip format done."


# 3-> Download and unzip latest code files
echo "Moving dotCMS artifacts to dotCMS project location..."

rm -rf ${APP_DIR}/dotCMS

if [ -f ${APP_DIR}/dotCMS.zip ]
then
    rm ${APP_DIR}/dotCMS.zip
fi

cp -r ${GIT_DOWNLOAD_DIR}/dotCMS.zip ${APP_DIR}

cd ${APP_DIR}

unzip -q -o dotCMS.zip -d .
find . -type f -iname "*.sh" -exec chmod u+x {} +
echo "dotCMS artifacts are moved and extracted in project folder"


# 4-> Deploy dotCMS application to AWS Elastic Beanstalk

cd ${APP_DIR}/aws/prod/bin/ebAutomations

${AWS_CLI_EXEC_PATH}/aws --version

echo "Calling 'deployAppToEB' to deploy application to AWS Elastic Beanstalk"

./deployAppToEB.sh ${AWS_PROFILE_NAME} ${S3_BUCKET_NAME_APP} ${EB_APPLICATION_NAME} ${EB_ENVIRONMENT_NAME} ${AWS_CLI_EXEC_PATH}

echo "Application deployment to AWS Elastic Benastalk is done."


# 5-> Removing extra files used during deployment
rm ${APP_DIR}/dotCMS.zip
rm ${GIT_DOWNLOAD_DIR}/dotCMS.zip