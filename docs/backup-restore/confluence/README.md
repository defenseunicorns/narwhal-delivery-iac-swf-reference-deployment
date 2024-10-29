# Confluence Backup and Restore

## Non-Native Backup and Restore

Confluence is backed up via AWS native resources similar to the other services. All backups happen automatically and are kept for, at minimum, 30 days.

This folder describes how the backup mechanisms work and how to restore from a backup. However, these documents will only cover restoring to a new cluster while the old cluster's resources still exist. Each resource type has it's own document.

### Confluence Database (RDS Postgres)

Confluence's database is backed up via AWS RDS snapshots. More info [here](confluence-database.md)

### Confluence Repository Volume

Confluence has two volumes that are backed up via snapshots of the EBS volume that the confluence pod stores data on. This happens via the Data Lifecycle Manager (DLM). More info [here](confluence-repo-pvc.md)
