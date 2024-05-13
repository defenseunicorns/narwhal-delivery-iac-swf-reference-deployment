# GitLab Backup and Restore

GitLab is backed up via AWS native resources and velero. All backups happen automatically and are kept for, at minimum, 30 days.

This folder describes how the backup mechanisms work and how to restore from a backup. However, these documents will only cover restoring to a new cluster while the old cluster's resources still exist. Each resource type has it's own document.

## Resource Overview

### Gitlab Database (RDS Postgres)

GitLab's database is backed up via AWS RDS snapshots. More info [here](gitlab-database.md)

### Gitlab Object Storage (S3)

GitLab's object storage is backed up via versioning being enabled on the S3 buckets. More info [here](gitlab-object-storage.md)

### Gitlab Secrets

GitLab has a few secrets that are generated on initial startup that must be carried over when restoring from a backup. These are stored in cluster and backed up via velero to an S3 bucket. More info [here](gitlab-secrets.md)

### Gitaly Repository Volume

Gitaly is backed up via snapshots of the EBS volume that the gitaly pod stores data on. This happens via the Data Lifecycle Manager (DLM). More info [here](gitaly-repo-pvc.md)

## Gitlab Restore Notes

There is some order to restoring GitLab. The order is as follows:

1. Restore the database from a snapshot
2. Copy objects into new buckets
3. Copy backed up secrets into new cluster
4. Follow Gitaly restore process
