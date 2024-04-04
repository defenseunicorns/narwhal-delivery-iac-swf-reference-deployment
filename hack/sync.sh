#!/bin/bash

set -euo pipefail

SRC_ENV=$1
DEST_ENV=$2

SRC_CONFIG="iac/env/${SRC_ENV}/uds/uds-config.yaml"
DEST_CONFIG="iac/env/${DEST_ENV}/uds/uds-config.yaml"

SRC_GITLAB_BUCKETS="$(cat ${SRC_CONFIG} | yq '.variables.gitlab' | grep bucket | yq .[])"
DEST_GITLAB_BUCKETS="$(cat ${DEST_CONFIG} | yq '.variables.gitlab' | grep bucket | yq .[])"

SRC_ZARF_BUCKET="$(cat ${SRC_CONFIG} | yq '.variables.zarf-init-s3-backend.registry_extra_envs' | yq '.[]' | grep BUCKET -A1 | yq '.value')"
DEST_ZARF_BUCKET="$(cat ${DEST_CONFIG} | yq '.variables.zarf-init-s3-backend.registry_extra_envs' | yq '.[]' | grep BUCKET -A1 | yq '.value')"

SRC_MATTERMOST_BUCKET="$(cat ${SRC_CONFIG} | yq '.variables.mattermost.mattermost_bucket')"
DEST_MATTERMOST_BUCKET="$(cat ${DEST_CONFIG} | yq '.variables.mattermost.mattermost_bucket')"

SRC_VELERO_BUCKET="$(cat ${SRC_CONFIG} | yq '.variables.core.VELERO_BACKUP_STORAGE_LOCATION[].bucket')"
DEST_VELERO_BUCKET="$(cat ${DEST_CONFIG} | yq '.variables.core.VELERO_BACKUP_STORAGE_LOCATION[].bucket')"

SRC_BUCKETS=($SRC_GITLAB_BUCKETS $SRC_ZARF_BUCKET $SRC_MATTERMOST_BUCKET $SRC_VELERO_BUCKET)
DEST_BUCKETS=($DEST_GITLAB_BUCKETS $DEST_ZARF_BUCKET $DEST_MATTERMOST_BUCKET $DEST_VELERO_BUCKET)

IDX=0

for i in "${SRC_BUCKETS[@]}"
do
  echo "source bucket: ${i} dest bucket: ${DEST_BUCKETS[$IDX]}"
  read -p "Press enter to continue"
  aws s3 sync "s3://${i}" "s3://${DEST_BUCKETS[$IDX]}"
  echo "Done"
  IDX=$((IDX+1))
done