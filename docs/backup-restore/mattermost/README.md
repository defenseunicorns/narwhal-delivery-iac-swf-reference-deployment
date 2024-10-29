# Mattermost Backup and Restore

Mattermost is backed up via AWS native resources. All backups happen automatically and are kept for, at minimum, 30 days.

This folder describes how the backup mechanisms work and how to restore from a backup. However, these documents will only cover restoring to a new cluster while the old cluster's resources still exist. Each resource type has it's own document.

## Resource Overview

### Mattermost Database (RDS Postgres)

Mattermost's database is backed up via AWS RDS snapshots. More info [here](mattermost-database.md)

### Mattermost Object Storage (S3)

Mattermost's object storage is backed up via versioning being enabled on the S3 buckets. More info [here](mattermost-object-storage.md)
