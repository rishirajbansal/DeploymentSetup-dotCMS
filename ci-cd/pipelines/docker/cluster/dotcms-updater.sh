#!/bin/bash

# 1. Pull code from GitHub
# 2. Update application on dotCMS docker Container

#set -x #echo on

# GIT_DOWNLOAD_DIR=$1
# APP_DIR=$2

#cd ${GIT_DOWNLOAD_DIR}
cd ${APP_DIR}

# mkdir -p dotCMS
# cd dotCMS

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

git pull origin ${GIT_BRANCH_NAME}

# git fetch --progress -- ${GIT_REPO_URL} +refs/heads/master:refs/remotes/origin/master # timeout=120
# git checkout origin/master

#echo "Git code saved in : ${GIT_DOWNLOAD_DIR}"
echo "Git code for dotCMS Application saved in : ${APP_DIR}"
echo

# # 2-> Zip git folder
# if [ -f ${GIT_DOWNLOAD_DIR}/dotCMS.zip ]
# then
#     rm ${GIT_DOWNLOAD_DIR}/dotCMS.zip
# fi  

# echo "Compressing dotCMS Artifcats in zip..."
# cd ${GIT_DOWNLOAD_DIR}/dotCMS
# zip -r -q ${GIT_DOWNLOAD_DIR}/dotCMS.zip . -x '*.git*'
# echo "Compression of dotCMS Artifcats in zip format done."

# # 3-> Download and unzip latest code files
# echo "Moving dotCMS artifacts to dotCMS project location..."

# rm -rf ${APP_DIR}/dotCMS

# if [ -f ${APP_DIR}/dotCMS.zip ]
# then
#     rm ${APP_DIR}/dotCMS.zip
# fi

# cp -r ${GIT_DOWNLOAD_DIR}/dotCMS.zip ${APP_DIR}

# cd ${APP_DIR}

# unzip -q -o dotCMS.zip -d .
# find . -type f -iname "*.sh" -exec chmod u+x {} +
# echo "dotCMS artifacts are moved and extracted in project folder"

find . -type f -iname "*.sh" -exec chmod u+x {} +

# 4-> Deploy dotCMS application container(s)
echo
echo "Building dotCMS docker container with new Project artifacts..."
echo "App Launch Environment : "${APP_LAUNCH_ENV}

if [ "$APP_LAUNCH_ENV" = "local" ] 
then
    cd ${APP_DIR}/appLauncher/local/

    ./launchApp-local.sh ${CONTAINERS_TO_DEPLOY}

else
    cd ${APP_DIR}/appLauncher/cluster/

    ./launchApp-cluster.sh ${CONTAINERS_TO_DEPLOY}
fi

if [ $? -ne 0 ]; then
    echo "Error occued while building docker containers, process will be terminated..."
    exit 1
else
    echo "Updated dotCMS docker container(s) with latest build is up and running."
fi

# 5-> Removing extra files used during deployment
# rm ${APP_DIR}/dotCMS.zip
# rm ${GIT_DOWNLOAD_DIR}/dotCMS.zip
