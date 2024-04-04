# GitLab Database Backup and Restore

GitLab stores data in a postgres database. We host this database in AWS RDS.

## Backup Mechanism

We configure RDS to take snapshots daily and retain snapshots for 30 days. These snapshots also have point-in-time recovery enabled.

## Restore Process

The database is definitely the easiest piece of gitlab to restore.

Prerequisites:

- Old environment up and in the same account
- The name of the snapshot you want to restore from
  - RDS -> Databases -> Old Database -> Maintenance & backups -> Snapshots

Steps:

- Modify the terraform vars for the new environment with the following variable, replacing `<snapshot-name>` with the snapshot name you want to restore from:

  ```hcl
  gitlab_db_snapshot = "<snapshot-name>"
  ```

- On terraform apply this will create a new RDS instance based on the snapshot you provided. This process can take a long time, especially if there is a version difference between the databases.
- Please make sure that all databases that need to be restored have their variables set for snapshots before the first terraform apply, the snapshot name variable only has an effect on the first apply.
