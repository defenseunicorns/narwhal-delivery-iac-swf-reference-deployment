# Jenkins Backup and Restore

Jenkins is backed up via AWS native resources. All backups happen automatically and are kept for, at minimum, 30 days.

This folder describes how the backup mechanisms work and how to restore from a backup. However, these documents will only cover restoring to a new cluster while the old cluster's resources still exist.

## Resource Overview

### Jenkins Repository Volume

Jenkins is backed up via snapshots of the EBS volume that the jenkins pod stores data on. This happens via the Data Lifecycle Manager (DLM). More info [here](jenkins-repo-pvc.md)
