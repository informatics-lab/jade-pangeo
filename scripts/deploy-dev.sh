#!/bin/bash
set -e

# # Vars
# SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# REPO_DIR=$SCRIPT_DIR/..

# # Install tools
# echo "*** Install helm ***"
# apt-get install git -y
# curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > ./helm-install.sh
# chmod +x ./helm-install.sh
# ./helm-install.sh

# echo "*** Install kubectl ***"
# apt-get update && apt-get install -y apt-transport-https
# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
# touch /etc/apt/sources.list.d/kubernetes.list 
# echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
# apt-get update
# apt-get install -y kubectl


# # Set up ssh
# echo "*** Install ssh keys ***"
# mkdir -p ~/.ssh
# cat << EOF > ~/.ssh/config
# Host *
#     StrictHostKeyChecking no

# EOF

# echo $SSH_KEY | base64 -d > ~/.ssh/id_rsa
# chmod 400  ~/.ssh/id_rsa

# # Link secrets
# echo "*** Link in secrets ***"
# cd $REPO_DIR/..
# git clone $SECRETS_REPO secrets
# cd $REPO_DIR
# ln -s $(cd ..; pwd)/secrets/jade-pangeo/dev/secrets.yaml ./env/dev/secrets.yaml


# # Setup kubectl config from template
# echo "*** Set up kube config ***"
# mkdir -p ~/.kube/
# python <<EOF >~/.kube/config
# import os
# with open('./k8-config.yaml') as fp:
#     print (os.path.expandvars(fp.read()))
# EOF

# # helm client version may differ from server version. Find out the server version and install that if different.
# echo "*** Downgrade helm if client version doesn't match server ***"
# HVERSION=$(helm version -s --short | cut -d ' '  -f 2 | cut -d '+' -f 1)
# ./helm-install.sh --version $HVERSION


echo "*** Deploy ***"
# init helm
helm init


# Add upstream pangeo repo and update
helm repo add pangeo https://pangeo-data.github.io/helm-chart/
helm repo update

# Get deps
helm dependency update jadepangeo

# Apply changes
helm upgrade $RELEASE_NAME jadepangeo -f env/dev/values.yaml -f env/dev/secrets.yaml


echo "*** Deployed successfully ***"