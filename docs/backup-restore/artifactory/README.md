# Artifactory Backup and Restore

Artifactory is backed up via AWS native resources. All backups happen automatically and are kept for, at minimum, 30 days.

This folder describes how the backup mechanisms work and how to restore from a backup. However, these documents will only cover restoring to a new cluster while the old cluster's resources still exist. Each resource type has it's own document.

## Resource Overview

### Artifactory Database (RDS Postgres)

Artifactory's database is backed up via AWS RDS snapshots. More info [here](artifactory-database.md)

### Artifactory Object Storage (S3)

Artifactory's object storage is backed up via versioning being enabled on the S3 buckets. More info [here](artifactory-object-storage.md)

### Artifactory Repository Volume

Artifactory is backed up via snapshots of the EBS volume that the artifactory pod stores data on. This happens via the Data Lifecycle Manager (DLM). More info [here](artifactory-repo-pvc.md)

## Artifactory Restore Notes

There is some order to restoring Artifactory. The order is as follows:

1. Restore the database from a snapshot
2. Copy objects into new buckets
3. Create pv using snapshot volume (example [here](./files/artifactory-pv.yaml))
4. Create pvc using snapshot volume (example [here](./files/artifactory-pvc.yaml))
5. Follow Artifactory restore process
