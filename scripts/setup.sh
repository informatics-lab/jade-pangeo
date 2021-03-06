#!/bin/bash
set -e

# Vars
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR=$SCRIPT_DIR/..

# Install tools
echo "*** Install helm ***"
sudo apt-get install git -y
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > ./helm-install.sh
chmod +x ./helm-install.sh
sudo ./helm-install.sh

echo "*** Install kubectl ***"
sudo apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo touch /etc/apt/sources.list.d/kubernetes.list
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl


# Set up ssh
echo "*** Install ssh keys ***"
mkdir -p ~/.ssh
cat << EOF > ~/.ssh/config
Host *
    StrictHostKeyChecking no

EOF

echo $SSH_KEY | base64 -d > ~/.ssh/id_rsa
chmod 400  ~/.ssh/id_rsa

# Link secrets
echo "*** Link in secrets ***"
cd $REPO_DIR/..
git clone $SECRETS_REPO secrets
cd $REPO_DIR
for dir in env/*; do
    env=${dir##*/}
    ln -s $(cd ..; pwd)/secrets/jade-pangeo/${env}/secrets.yaml ./env/${env}/secrets.yaml
done


# Setup kubectl config from template
echo "*** Set up kube config ***"
mkdir -p ~/.kube/
python <<EOF >~/.kube/config
import os
with open('./k8-config.yaml') as fp:
    print (os.path.expandvars(fp.read()))
EOF

# helm client version may differ from server version. Find out the server version and install that if different.
echo "*** Downgrade helm if client version doesn't match server ***"
HVERSION=$(helm version -s --short | cut -d ' '  -f 2 | cut -d '+' -f 1)
sudo ./helm-install.sh --version $HVERSION

echo "*** Set up complete ***"
