# GitLab Secrets Backup and Restore

On initial deployment Gitlab generates a few secrets that all of it's other data is based on and which cannot be accessed without. This secret is stored in the cluster.

## Backup Mechanism

The secrets are backed up via velero to an S3 bucket. Due to the limitations of velero selectors there are more secrets backed up than necessary. Out of the secrets that are backed up, the ones that are necessary for gitlab to function are:

- `gitlab-initial-root-password`
- `gitlab-rail-secret`

## Restore Process

Prerequisites:

- New environment (terraform infra) stood up
- Bundle installed up to UDS-Core
  - Velero is up and healthy
  - Velero has access to old env backup bucket or the objects from old env bucket have been copied to new bucket
- Velero CLI installed

Steps:

- Get the name of the latest rails backup
  - Run `velero backup get`
  - Note the name of the latest backup named `gitlab-rails-backup-<Date>`
- Restore the backup
  - Run `velero restore create --from-backup gitlab-rails-backup-<Date>`
  - This will create all of the secrets contained in the backup, in the cluster.
- Delete unnecessary restored secrets
  - Due to a lack of more selector logic in velero there are more secrets restored than what we need/want
  - Out of the secrets that velero created we only want `gitlab-initial-root-password` and `gitlab-rail-secret`. All other secrets created by velero should be deleted.

If the velero CLI is not available, all of the above is possible via velero CRDs. However this is not covered here and you will need to reference velero documentation.
