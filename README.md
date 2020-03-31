# Deployment Setup [CI/CD - Pipelines] for dotCMS Application

## Contents

1. [Overview](#overview)
2. [Prerequisites](#Prerequisites)
3. [Setup Steps](#Setup-steps)
4. [Jenkins Environment Properties Configuration](#Jenkins-environment-properties-configuration)


## Overview

Automated release management for deploying dotCMS application on remote Development server. This is achieved through CI/CD pipeline, which imports latest project artifacts from GitHub Repository and deploy them to remote server on which dotCMS application is running, it executes all prerequisites required to setup the application. 

CI/CD Pipeline is implemented in Jenkins server which runs inside the Docker in local host machine. Jenkins pipeline connects with remote machine via secure SSH protocol based on private/public keypair authentication. It deploys the project artifacts in remote server and then build up new Docker image with latest code. It starts new Docker container for dotCMS application and bring up dotCMS application up to be accessible from outside of remote machine.


### Machines Configuration

Following configuration is assumed for this setup:

| Local Machine  | Remote Machine (Server) |
| ------------- | ------------- |
| - Jenkins running inside Docker  | - Swarm Initialized |
| - SSH keypair configured to access Remote Server | - Overlay Network created |
|  | - PostgreSQL DB on Docker Container |
|  | - NFS Server on Docker |
|  | - dotCMS Application on Docker (via Jenkins) |


## Prerequisites

Remote Machine (Server) should already be setup with following configuration:

- Swarm is already initialized and setup as a manager node
- 'Overlay' Driver Network created 
- PostgreSQL database running inside Docker and up
- NFS server running inside Docker and up


## Setup Steps

1. [Jenkins Setup in Docker](#Jenkins-setup-in-docker)
2. [SSH Setup for Remote Machine (Server)](#SSH-setup-for-remote-machine-server)
3. [Credentials Setup in Jenkins](#credentials-setup-in-jenkins)
4. [Pipeline Setup in Jenkins](#Pipeline-setup-in-jenkins)

## Jenkins Setup in Docker

Jenkins will be installed on local machine inside Docker.

To install Jenkins using Docker compose, execute following:

```
$ cd /path/to/DeploymentSetup-dotCMS/ci-cd/jenkins
$ docker-compose up --build -d
```

This will install Jenkins on Docker container and will also mount Jenkins files/folders to the directory `jenkinsData` which can help to inspect workspaces, jobs, logs or any other relevant information of Jenkins and thus avoiding to access Docker container to check these files.

### Accessing Jenkins 

Jenkins will be available to access at http://machine-ip:8085/

On first time access, it will ask the Administrator password to access the application. To get the administrator password, check the logs of Jenkins Docker container, it will be printed somewhere at the end of logs, as shown below:

```
$ docker container logs dotcms-jenkins

*************************************************************
Jenkins initial setup is required. An admin user has been created and a password generated.
Please use the following password to proceed to installation:

403ba6afb9814d938dd670aba7dca7ca

This may also be found at: /var/jenkins_home/secrets/initialAdminPassword
*************************************************************
```

- Get the password from the logs and enter in the screen to continue. 
- In next screen, click “Install suggested plugins”. Wait until the plugins installations completed.
- In the next screen, Create Admin user.

This will complete Jenkins installation and setup.

## SSH Setup for Remote Machine (Server)

Setup SSH to access remote Machine from local Machine (where Jenkins will be running)

1. On local host machine, generate SSH Key pair to communicate with remote instance securely via SSH

    ```
	ssh-keygen -t rsa -b 4096 -C "dotcmsl@dynamictype.com"
	```

    It will ask to enter the path to save the key credentials, recommended path is to store the keys along with other dotCMS application files. For Instance:

    `/path/to/dotcms/sshkey/dotcms_sshkey`

	It will ask to type a secure passphrase, it can be ignored and empty passphrase will be accepted.

2. 	Once an SSH key has been created, the `ssh-copy-id` command can be used to install it as an authorized key on the server. Once the key has been authorized for SSH, it grants access to the server without a password.

    ```
    ssh-copy-id -i /path/to/sshkey/dotcms_sshkey user@remote-machine-ip
    ```

    This logs into the remote server host, and copies keys to the server, and configures them to grant access by adding them to the authorized_keys file. 


## Credentials Setup in Jenkins

### Setup Credentials to access Private GitHub Repository

To pull the code from GitHub in Shell script, authentication with GitHub is required. For successful authentication, it is required to setup GitHub access credentials securely which is used in shell script via Jenkins credentials plugin. Jenkins will automatically authenticates with GitHub to access private GitHub repository in shell script.

To setup GitHub credentials, open:
*Jenkins -> Credentials -> System -> Global credentials (unrestricted)*

Provide GitHub account username & password in the screen.

*Note: Ensure Git Plugin is setup in Jenkins*

Add Git Credentials as shown in the following screen:

![GitHub Credentials Setup in Jenkins](/documentation/github_cred_setup.png)

### Setup SSH Keypair credentials to access remote machine (server)

To access remote machine from the script (via Jenkins) using SSH, it is required to use SSH private key as a credential to connect with remote machine (server). To avoid saving this key file in GitHub or any other place, the SSH private key can be setup in Jenkins to keep it secure and disallowing any vulnerabilities. 

*The private key is stored on the client device, and the public key is transferred to remote server as done during SSH Setup in one of the above step.*

To setup SSH key in Jenkins, open:
*Jenkins -> Credentials -> System -> Global credentials (unrestricted)*

Provide unique ID (`DOTCMS_REMOTE_APPLICATION_SERVER`) that will be used in Jenkinsfile to identify the SSH account. Copy the content from SSH Private key and paste down to the Private Key text box.

Add SSH Key Credentials as shown in the following screen:

![SSH Key Credentials Setup in Jenkins](/documentation/ssh_cred_setup.png)


## Pipeline Setup in Jenkins

Create new Pipeline in Jenkins based on the general pipeline type project.

- Pipeline Definition comes from SCM based Git project. 
- Enter the Git Repository URL which contains Jenkins and other supported files.
- Provide credentials  to access Git. 
- Enter the branch name.
- Enter the path of Jenkinsfile.

Following image depicts Jenkins pipeline creation as a reference:

![Jenkins Pipeline Creation](/documentation/jenkins_pipeline.png)


## Jenkins Environment Properties Configuration

Jenkins file settings are configurable and can be modified based on the environment.

To change the settings, update `ci-cd/pipelines/dev/env.properties` file.

Following table details out the properties that can be configured for pipeline settings.

| Property  | Description |
| ------------- | ------------- |
| GIT_REPO_URL  | GitHub Repository URL (https form) of dotCMS application |
| GIT_BRANCH_NAME  | GitHub Branch used to download the code  |
| GIT_CREDENTIALS_ID | Credential ID generated in Jenkins for GitHub Access in Global Credentials  |
| GIT_DOWNLOAD_DIR | Path on Remote Machine (Server) where the Git files will be downloaded |
| APP_DIR | Path on Remote Machine (Server) where the dotCMS application project artifacts will be deployed |
| REMOTE_SERVER_INSTANCE_USER | Remote Machine User name of machine |
| REMOTE_SERVER_INSTANCE_IP | Remote Machine IP |
| NFS_CONTAINER_IP | Remote Machine IP (NFS Docker container will be running on remote machine) |
| DB_CONTAINER_NAME | Container Name of PostgreSQL Database |
| NFS_CONTAINER_NAME | Container Name of NFS |
| APP_CONTAINER_NAME | Container Name of dotCMS application |
| APP_IMAGE_NAME | Image name of dotCMS application |
| VOLUME_NFS | Name of Docker Volume used by NFS Docker container for Mount |
| DOTCMS_APP_PORT | Published Port of dotCMS application running inside Docker container |
