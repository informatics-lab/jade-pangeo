# The script is a saftey measure and patches your PersistentVolumes (PV) to
# not be garbage collected if the PersistentVolumeClaim (PVC) are deleted.
NAMESPACE=jupyter

# Store the name of the Helm release
RELEASE_NAME=jupyterhub.informaticslab.co.uk


# Ensure the hub's and users' data isn't lost
hub_and_user_pvs=($(kubectl get persistentvolumeclaim --no-headers --namespace $NAMESPACE | awk '{print $3}'))
for pv in ${hub_and_user_pvs[@]};
do
    kubectl patch persistentvolume $pv --patch '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
done



# Look up the name of your Helm release (installation of a Helm chart)
helm list


# Give yourself an overview of this release's revisions
helm history $RELEASE_NAME

# Check if you have multiple revisions in a DEPLOYED status (a bug), or if you
# have old PENDING_UPGRADES or FAILED revisions (may be problematic).
helm history $RELEASE_NAME | grep --extended-regexp "DEPLOYED|FAILED|PENDING_UPGRADE"

# If you have multiple revisions in DEPLOYED status, this script will clean up
# all configmaps except the latest with DEPLOYED status.
deployed_revisions=($(helm history $RELEASE_NAME | grep DEPLOYED | awk '{print $1}'))
for revision in ${deployed_revisions[@]::${#deployed_revisions[@]}-1};
do
    kubectl delete configmap $RELEASE_NAME.v$revision --namespace kube-system
done

# It seems plausible that upgrade failures could have to do with revisions
# having a PENDING_UPGRADE or FAILED status in the revision history. To delete
# them run the following command.
kubectl delete configmap --selector "NAME=$RELEASE_NAME,STATUS in (FAILED,PENDING_UPGRADE)" --namespace kube-system






helm upgrade jupyterhub.informaticslab.co.uk jadepangeo -f env/prod/values.yaml -f env/prod/secrets.yaml --force