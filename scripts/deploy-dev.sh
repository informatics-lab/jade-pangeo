#!/bin/bash
set -e

# Vars
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR=$SCRIPT_DIR/..

# Install tools
apt-get install git -y
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash

apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
touch /etc/apt/sources.list.d/kubernetes.list 
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubectl


# Set up ssh
mkdir -p ~/.ssh
cat << EOF > ~/.ssh/config
Host *
    StrictHostKeyChecking no

EOF

echo $SSH_KEY | base64 -d > ~/.ssh/id_rsa
chmod 400  ~/.ssh/id_rsa

# Link secrets
cd $REPO_DIR/..
git clone $SECRETS_REPO secrets
cd $REPO_DIR
ln -s ../secrets/jade-pangeo/env/dev/secrets.yaml ./env/dev/secrets.yaml


# Setup kubectl config from template
mkdir -p ~/.kube/
while read line
do
    eval echo "$line"
done < "./template.txt" > ~/.kube/config



# init helm
helm init


# Add upstream pangeo repo and update
helm repo add pangeo https://pangeo-data.github.io/helm-chart/
helm repo update

# Get deps
helm dependency update jadepangeo

# Apply changes
helm upgrade $RELEASE_NAME jadepangeo -f env/dev/values.yaml -f env/dev/secrets.yaml






