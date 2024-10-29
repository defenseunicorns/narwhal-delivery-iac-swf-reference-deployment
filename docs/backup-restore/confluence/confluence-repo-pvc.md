# Confluence Backup and Restore

Confluence stores repository data in the volumes mounted to it's pod. These volumes are backed by an AWS EBS volume. They are named `local home` and `shared home`.

## Backup Mechanism

The EBS volume used by confluence is backed up via EBS snapshots. These snapshots are scheduled and taken by the Data Lifecycle Manager (DLM). The terraform relating to it's configuration is [here](../../iac/swf/confluence.tf) under the `confluence_volume_snapshots` module. This information can also be found in the AWS Console on the EC2 page under `Elastic Block Store` -> `Lifecycle Manager`.

## Restore Process

### Prerequisites

- New environment (terraform infra) stood up
- Bundle installed up to right before the confluence package
  - **Do not install the confluence package yet**
  - Bundle installation can either be cancelled before confluence or you can give the `uds deploy` command the `-p` flag to specify all packages before confluence
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

Confluence requires both PVCs (`CONFLUENCE_LOCAL_HOME_PVC_CUSTOM_VOLUME` and `CONFLUENCE_SHARED_HOME_PVC_CUSTOM_VOLUME`) to be fully restored.

#### Local Home PVC

1. Modify the `uds-config.yaml` for the environment you're deploying to
    - Set the `CONFLUENCE_LOCAL_HOME_PVC_CUSTOM_VOLUME` to the name you'll be applying to the new confluence pvc.

    - Example:

      ```yaml
        confluence:
            CONFLUENCE_LOCAL_HOME_PVC_CUSTOM_VOLUME: "confluence-local-home-pvc"
      ```

2. Create the new confluence EBS volume
    - Create a new EBS volume
        - Confirm that the volume size matches the requested size in the confluence PVC (default: `50Gi`)
        - The tag that DLM is looking for can be found in the AWS Console: `Elastic Block Store` -> `Lifecycle Manager` -> `Modify` -> `Step 1 Specify Settings` -> `Target resource tags`
        - Add that tag to the volume
        - Create the new volume
    - Verify later that the volume has been snapshotted by DLM
    - Note the volume id (ex. `vol-093116130d780e5e4`) for step 3

3. Create the new confluence local home pv. - [Example PersistentVolume Manifest](files/confluence-local-pv.yaml)
    - Name can be anything (ex. `confluence-restored-local-volume`)
    - Labels can be anything
    - The volume id must be the id of the volume you created in step 2
    - The storage must be the same as the volume you created in step 2 and match the Confluence PVC request (ex. `50Gi`)
    - Apply your PV

4. Create the new confluence local home pvc. - [Example PersistentVolumeClaim Manifest](files/confluence-local-pvc.yaml)
    - Name must match the name you set in step 1 (ex. `confluence-restored-local-volume`)
    - Labels can be anything
    - Namespace should match the namespace confluence will be deployed to
    - The volume name must be the name of the volume you created in step 3
    - The `resources.requests.storage` must be the same as the persistent volume capacity you created in step 3 (ex. `50Gi`)
    - Apply your PVC

#### Shared Home PVC

1. Modify the `uds-config.yaml` for the environment you're deploying to
    - Set the `CONFLUENCE_SHARED_HOME_PVC_CUSTOM_VOLUME` to the name you'll be applying to the new confluence pvc.

    - Example:

      ```yaml
        confluence:
            CONFLUENCE_SHARED_HOME_PVC_CUSTOM_VOLUME: "confluence-shared-home-pvc"
      ```

2. Create the new confluence shared home pv. - [Example PersistentVolume Manifest](files/confluence-shared-pv.yaml)
    - Name can be anything (ex. `confluence-restored-shared-volume`)
    - Labels can be anything
    - To get the correct access point, look at the PV for `confluence-shared-home` under `spec.csi.volumeHandle`
        - Example: `fs-0b51de256d5341ac9::fsap-0da1f241b93d51b15`
    - The `[FileSystemId]` needs to be set to the correct value that can be found in the AWS console under: `EFS` -> `File system ID`
    - The `[AccessPointID]` needs to be set to the correct value that can be found in the AWS console under: `EFS` -> `File system ID` -> `Access points`
    - Apply your PV

3. Create the new confluence shared home pvc. - [Example PersistentVolumeClaim Manifest](files/confluence-shared-pvc.yaml)
    - Name must match the name you set in step 1 (ex. `confluence-restored-shared-volume`)
    - Labels can be anything
    - Namespace should match the namespace confluence will be deployed to
    - The volume name must be the name of the volume you created in step 2
    - The `resources.requests.storage` must be the same as the persistent volume capacity you created in step 3 (ex. `50Gi`)
    - Apply your PVC

#### After both Local and Shared are restored

1. Deploy the confluence package via the bundle(can use `-p` flag or just wait till it gets to confluence)

    ***NOTE***

    - There is a chance that the confluence pod and the volume created in step 2 are not in the same availability zone. This will cause the pod to never show healthy and remain stuck at initing. You can check if this is the case by describing the pod, and looking for an error in the events section.

    - An example error message is:

        ```sh
        status code: 400, request id: 8b39d679-c1a9-4b91-ae97-d1064d0d69ff
        Warning  FailedAttachVolume  0s  attachdetach-controller  AttachVolume.Attach failed for volume "confluence-volume" : rpc error: code = Internal desc = Could not attach volume "vol-0a5410ba3acbc7b6a" to node "i-0f0aeaee254ea5ce5": could not attach volume "vol-0a5410ba3acbc7b6a" to node "i-0f0aeaee254ea5ce5": InvalidVolume.ZoneMismatch: The volume 'vol-0a5410ba3acbc7b6a' is not in the same availability zone as instance 'i-0f0aeaee254ea5ce5'
        ```

    - To get the correct availability zone, see what node the pod is attached to, and check the corresponding node's availability zone

    - Should this error appear:

        - Delete the pv and pvc created in steps 2 & 3

        - Repeat steps 2-4, but note in step 2 that you must create the volume with the same availability zone as the node that confluence is attached to.

    - When the pv and pvc are available in the cluster, perform step 5 again

2. The confluence pod should come up healthy and have its data restored
