# Gitaly Backup and Restore

Gitaly stores repository data in the volume mounted to it's pod. This volume is backed by an AWS EBS volume.

## Backup Mechanism

The EBS volume used by gitaly is backed up via EBS snapshots. These snapshots are scheduled and taken by the Data Lifecycle Manager (DLM). The terraform relating to it's configuration is [here](../../iac/swf/gitlab.tf) under the `gitlab_volume_snapshots` module. This information can also be found in the AWS Console on the EC2 page under `Elastic Block Store` -> `Lifecycle Manager`.

## Restore Process

### Prerequisites

- New environment (terraform infra) stood up
- Gitlab database restored
- Gitlab object storage restored
- Gitlab secrets restored
- Bundle installed up to right before the gitlab package
  - **Do not install the gitlab package yet**
  - Bundle installation can either be cancelled before gitlab or you can give the `uds deploy` command the `-p` flag to specify all packages before gitlab
  - Example usage of `-p` flag:

    ```sh
    export UDS_CONFIG='path to uds-config.yaml'
    uds deploy "path to uds bundle" --confirm -p \
    zarf-init-s3-backend \
    storageclass \
    aws-load-balancer-controller \
    core \
    cluster-autoscaler \
    aws-node-termination-handler \
    swf-deps-aws
    ```

### Steps

1. Modify the `uds-config.yaml` for the environment you're deploying to
    - Set the `GITALY_PV_MATCH_LABELS` to the labels you'll be applying to the new gitaly pv. ex:

      ```yaml
      GITALY_PV_MATCH_LABELS:
        label1: value1
        label2: value2
      ```

2. Create the new gitaly EBS volume
    - Create a new EBS volume
        - The volume must be created in the same availability zone as the dedicated gitaly node. This can be checked in the AWS Console under `EC2` -> `Instances` -> `Availability Zone Column` -> `prefix-gitaly_ng-suffix`
        - Confirm that the volume size matches the requested size in the gitaly PVC (default: `50Gi`)
        - The tag that DLM is looking for can be found in the AWS Console: `Elastic Block Store` -> `Lifecycle Manager` -> `Modify` -> `Step 1 Specify Settings` -> `Target resource tags`
        - Add that tag to the volume
        - Create the new volume
    - Verify later that the volume has beensnapshotted by DLM
    - Note the volume id (ex. `vol-093116130d780e5e4`) for step 3

3. Create the new gitaly pv. - [Example PersistentVolume Manifest](files/gitaly-pv.yaml)
    - Name can be anything (ex. `gitaly-volume`)
    - Labels must match what you put for `GITALY_PV_MATCH_LABELS` in the `uds-config.yaml`
    - The volume id must be the id of the volume you created in step 2
    - The storage must be the same as the volume you created in step 2 and match the Gitaly PVC request (ex. `50Gi`)
    - Apply your PV

4. Deploy the gitlab package via the bundle(can use `-p` flag or just wait till it gets to gitlab)
