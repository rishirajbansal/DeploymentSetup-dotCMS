#!/bin/bash

#set -x #echo on

echo
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

# git config --global --unset http.proxy 
# git config --global --unset https.proxy

git config remote.origin.url ${GIT_REPO_URL_AUTH} 
git config --global http.postBuffer 1048576000

git pull origin ${GIT_BRANCH_NAME}

#echo "Git code saved in : ${GIT_DOWNLOAD_DIR}"
echo "Git code for dotCMS Application saved in : ${APP_DIR}"


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
# echo "Moving and unzipping dotCMS artifacts to dotCMS project location..."

# #rm -rf ${APP_DIR}/dotCMS
# rm -rf ${APP_DIR}/*

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

# 4-> Create and Upload - dotCMS App Bundle & EB Deployment Bundle to S3 bucket
cd ${APP_DIR}/aws/prod/bin/ebAutomations/dotcms

${AWS_CLI_EXEC_PATH}/aws --version

echo && echo "Calling 'createUploadAppBundle' to create and upload app bundle to S3"

./createUploadAppBundle.sh ${AWS_PROFILE_NAME} ${REGION} ${ENV} ${S3_BUCKET_NAME_APP} ${AWS_CLI_EXEC_PATH}

echo "Calling 'createUploadEBDeployBundle' to create and upload EB Deployment Bundle to S3"

./createUploadEBDeployBundle.sh ${AWS_PROFILE_NAME} ${REGION} ${ENV} ${S3_BUCKET_NAME_APP} ${AWS_CLI_EXEC_PATH}

if [ $? -ne 0 ]; then
    echo "Error occued while Creating and Uploading of App Bundle, process will be terminated..."
    exit 1
else
    echo "Creating and Uploading of App Bundle and EB Deploy Bundle is done."
fi


# 5-> Removing extra files used during deployment
#rm ${APP_DIR}/dotCMS.zip
#rm ${GIT_DOWNLOAD_DIR}/dotCMS.zip