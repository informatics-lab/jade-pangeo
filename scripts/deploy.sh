#!/bin/bash
set -e
echo "*** Deploy ***"

ENV=$1 # environment `dev` or `prod`
RELEASE_NAME=$2 # helm chart release name.

echo ENV=$1 RELEASE_NAME=$2

# init helm
helm init


# Add upstream pangeo repo and update
helm repo add pangeo https://pangeo-data.github.io/helm-chart/
helm repo update

# Get deps
helm dependency update jadepangeo

# Apply changes
helm upgrade $RELEASE_NAME jadepangeo -f env/$ENV/values.yaml -f env/$ENV/secrets.yaml


echo "*** Deployed successfully ***"