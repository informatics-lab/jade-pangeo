# The script is a saftey measure and patches your PersistentVolumes (PV) to
# not be garbage collected if the PersistentVolumeClaim (PVC) are deleted.
NAMESPACE=pangeo-dev

# Store the name of the Helm release
RELEASE_NAME=pangeo-dev.informaticslab.co.uk




# helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
# helm repo update


# helm upgrade pangeo-dev.informaticslab.co.uk jadepangeo -f env/dev/values.yaml -f env/dev/secrets.yaml

# NOTE: We need the --force flag to allow recreation of resources that can't be
#       upgraded to the new state by a patch.
helm upgrade $RELEASE_NAME jadepangeo --force \
    --namespace=$NAMESPACE \
    -f env/dev/values.yaml \
    -f env/dev/secrets.yaml 