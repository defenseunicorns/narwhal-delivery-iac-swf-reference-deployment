# Gitaly Backup and Restore

Gitaly stores repository data in the volume mounted to it's pod. This volume is backed by an AWS EBS volume.

## Backup Mechanism

The EBS volume used by gitaly is backed up via EBS snapshots. These snapshots are scheduled and taken by the Data Lifecycle Manager (DLM). The terraform relating to it's configuration is [here](../../iac/swf/gitlab.tf) under the `gitlab_volume_snapshots` module. This information can also be found in the AWS Console on the EC2 page under `Elastic Block Store` -> `Lifecycle Manager`.

## Restore Process

Prerequisites:

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

Steps:

1. Modify the `uds-config.yaml` for the environment you're deploying to
    - Set the `GITALY_PV_MATCH_LABELS` to the labels you'll be applying to the new gitaly pv. ex:

      ```yaml
      GITALY_PV_MATCH_LABELS:
        label1: value1
        label2: value2
      ```

2. Deploy the gitlab package via the bundle(can use `-p` flag or just wait till it gets to gitlab)
    - Gitlab should deploy successfully except for the gitaly pod. This is because it is looking for a specific volume that we haven't yet created
3. Create the new gitaly EBS volume
    - Check which node the gitaly pod is running on.
    - Correlate this to the ec2 instance that is in AWS and note it's availability zone
    - Create a new EBS volume in the same availability zone as the ec2 instance
        - Gitaly is [pretty iops heavy](https://docs.gitlab.com/ee/administration/gitaly/#disk-requirements) so make sure to edit the volume details to give it higher iops and throughput according to your use.
        - Confirm that the volume size matches the requested size in the gitaly PVC
        - Set the availability zone to match the instance you noted earlier
        - The new volume needs to be tagged correctly so that DLM will take snapshots of it
        - The tag that DLM is looking for can be found in the AWS Console: `Elastic Block Store` -> `Lifecycle Manager` -> `Modify` -> `Step 1 Specify Settings` -> `Target resource tags`
        - Add that tag to the volume
        - Create the new volume
    - Verify later that the volume has been snapshotted by DLM
    - Note the volume id (ex. `vol-06d23074ed3b6d44c`) for later
4. Create the new gitaly pv. - [Example PersistentVolume Manifest](files/gitaly-pv.yaml)
    - Name can be anything
    - Labels must match what you put for `GITALY_PV_MATCH_LABELS` in the `uds-config.yaml`
    - The volume id must be the id of the volume you created in step 3
    - The storage must be the same as the volume you created in step 3 and match the Gitaly PVC request (ex. `50Gi`)
    - Apply your PV
5. Delete the gitaly PVC
    - This will cause k8s to recognize the new PV you created and mount it.
