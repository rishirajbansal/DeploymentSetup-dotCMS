#!/bin/bash

# 1. Pull code from GitHub
# 2. Update application on dotCMS docker Container

set -x #echo on

# GIT_DOWNLOAD_DIR=$1
# APP_DIR=$2

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

git config remote.origin.url ${GIT_REPO_URL_AUTH} 
git config --global http.postBuffer 1048576000
# git config --global user.name "rishirajbansal"

git pull origin ${GIT_BRANCH_NAME}

# git fetch --progress -- ${GIT_REPO_URL} +refs/heads/master:refs/remotes/origin/master # timeout=120
# git checkout origin/master

echo "Git code saved in : ${GIT_DOWNLOAD_DIR}"

# 2-> Zip git folder
#cd ${GIT_DOWNLOAD_DIR}
if [ -f ${GIT_DOWNLOAD_DIR}/dotCMS.zip ]
then
    rm ${GIT_DOWNLOAD_DIR}/dotCMS.zip
fi

zip -r -q ${GIT_DOWNLOAD_DIR}/dotCMS.zip dotCMS/dotCMS/app/*

# 3-> Shut down dotCMS Container
docker container stop ${APP_CONTAINER_NAME}
echo "${APP_CONTAINER_NAME} Stopped."

docker container rm --force ${APP_CONTAINER_NAME}
echo "${APP_CONTAINER_NAME} Removed."

# 4-> Download and unzip latest code files
rm -rf ${APP_DIR}/*

if [ -f ${APP_DIR}/dotCMS.zip ]
then
    rm ${APP_DIR}/dotCMS.zip
fi

cp -r ${GIT_DOWNLOAD_DIR}/dotCMS.zip ${APP_DIR}

cd ${APP_DIR}

unzip dotCMS.zip -d .

# 5-> Start new Docker Container
cd ${APP_DIR}/app

# docker-compose up --build -d