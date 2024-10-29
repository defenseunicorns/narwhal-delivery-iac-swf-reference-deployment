# Sonarqube Backup and Restore

Sonarqube is backed up via AWS native resources. All backups happen automatically and are kept for, at minimum, 30 days.

This folder describes how the backup mechanisms work and how to restore from a backup. However, these documents will only cover restoring to a new cluster while the old cluster's resources still exist. Each resource type has it's own document.

## Resource Overview

### Sonarqube Database (RDS Postgres)

Sonarqube's database is backed up via AWS RDS snapshots. More info [here](sonarqube-database.md)

### Sonarqube Repository Volume

Sonarqube is backed up via snapshots of the EBS volume that the sonarqube pod stores data on. This happens via the Data Lifecycle Manager (DLM). More info [here](sonarqube-repo-pvc.md)
