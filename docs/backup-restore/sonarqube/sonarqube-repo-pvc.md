# Sonarqube Backup and Restore

***Note: If s3 is the backend, follow [this guide](./sonarqube-object-storage.md) instead***

Sonarqube stores repository data in the volume mounted to it's pod. This volume is backed by an AWS EBS volume.

## Backup Mechanism

The EBS volume used by sonarqube is backed up via EBS snapshots. These snapshots are scheduled and taken by the Data Lifecycle Manager (DLM). The terraform relating to it's configuration is [here](../../iac/swf/sonarqube.tf) under the `sonarqube_volume_snapshots` module. This information can also be found in the AWS Console on the EC2 page under `Elastic Block Store` -> `Lifecycle Manager`.

## Restore Process

### Prerequisites

- New environment (terraform infra) stood up
- Bundle installed up to right before the sonarqube package
  - **Do not install the sonarqube package yet**
  - Bundle installation can either be cancelled before sonarqube or you can give the `uds deploy` command the `-p` flag to specify all packages before sonarqube
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
    - Set the `SONARQUBE_PERSISTENCE_EXISTING_CLAIM` to the name you'll be applying to the new sonarqube pvc.

    - Example:

      ```yaml
        sonarqube:
            SONARQUBE_PERSISTENCE_EXISTING_CLAIM: "sonarqube-pvc"
      ```

2. Create the new sonarqube EBS volume
    - Create a new EBS volume
        - Confirm that the volume size matches the requested size in the sonarqube PVC (default: `50Gi`)
        - The tag that DLM is looking for can be found in the AWS Console: `Elastic Block Store` -> `Lifecycle Manager` -> `Modify` -> `Step 1 Specify Settings` -> `Target resource tags`
        - Add that tag to the volume
        - Create the new volume
    - Verify later that the volume has been snapshotted by DLM
    - Note the volume id (ex. `vol-093116130d780e5e4`) for step 3

3. Create the new sonarqube pv. - [Example PersistentVolume Manifest](files/sonarqube-pv.yaml)
    - Name can be anything (ex. `sonarqube-volume`)
    - Labels can be anything
    - The volume id must be the id of the volume you created in step 2
    - The storage must be the same as the volume you created in step 2 and match the Sonarqube PVC request (ex. `50Gi`)
    - Apply your PV

4. Create the new sonarqube pvc. - [Example PersistentVolumeClaim Manifest](files/sonarqube-pvc.yaml)
    - Name must match the name you set in step 1 (ex. `sonarqube-pvc`)
    - Labels can be anything
    - Namespace should match the namespace sonarqube will be deployed to
    - The volume name must be the name of the volume you created in step 3
    - The `resources.requests.storage` must be the same as the persistent volume capacity you created in step 3 (ex. `50Gi`)
    - Apply your PVC

5. Deploy the sonarqube package via the bundle(can use `-p` flag or just wait till it gets to sonarqube)

    ***NOTE***

    - There is a chance that the sonarqube pod and the volume created in step 2 are not in the same availability zone. This will cause the pod to never show healthy and remain stuck at initing. You can check if this is the case by describing the pod, and looking for an error in the events section.

    - An example error message is:

        ```sh
        status code: 400, request id: 8b39d679-c1a9-4b91-ae97-d1064d0d69ff
        Warning  FailedAttachVolume  0s  attachdetach-controller  AttachVolume.Attach failed for volume "sonarqube-volume" : rpc error: code = Internal desc = Could not attach volume "vol-0a5410ba3acbc7b6a" to node "i-0f0aeaee254ea5ce5": could not attach volume "vol-0a5410ba3acbc7b6a" to node "i-0f0aeaee254ea5ce5": InvalidVolume.ZoneMismatch: The volume 'vol-0a5410ba3acbc7b6a' is not in the same availability zone as instance 'i-0f0aeaee254ea5ce5'
        ```

    - To get the correct availability zone, see what node the pod is attached to, and check the corresponding node's availability zone

    - Should this error appear:

        - Delete the pv and pvc created in steps 2 & 3

        - Repeat steps 2-4, but note in step 2 that you must create the volume with the same availability zone as the node that sonarqube is attached to.

    - When the pv and pvc are available in the cluster, perform step 5 again

6. The sonarqube pod should come up healthy and have its data restored
