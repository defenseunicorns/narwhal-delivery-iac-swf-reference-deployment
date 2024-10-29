# Artifactory Object Storage Backup and Restore

Artifactory uses a bunch of different buckets to store data in. We have these buckets in AWS S3.

## Backup Mechanism

As of now there is no "snapshot" like backup mechanism for s3. Versioning is enabled, which allows an administrator to restore a previous version of a file if necessary.

## Restore Process

### Prerequisites

- New environment (terraform infra) stood up
- Have uds-config.yaml present in env folders for old and new infra (both up to date)

### Steps

From here things can get complicated.

If there isn't a massive amount of data in the buckets, there is a script provided in the `hack` folder of this repo called `sync.sh`. This script will parse all bucket names out of each env provided and run the `aws s3 sync` command to copy object to the new buckets. This does cover all buckets and not just artifactory so please be aware. You can comment out the variables in the script for objects you do not wish to sync. This script is not perfect and may need to be modified to fit your needs. If you do use it, it will ask for confirmation before each sync, please check that the bucket names listed are correct before proceeding.

If there are extreme amounts of data in each bucket you may be better off using an s3 batch operation to do the copy operation. This will involve creating an IAM role with proper permissions and modifying the KMS key policy for each bucket to allow the new role to decrypt and encrypt objects. You may also need to modify the principal for KMS/IAM things to allow `s3.amazonaws.com` and `batchoperations.s3.amazonaws.com`. This is not covered in detail here but these are some links that should help with the process.

- <https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-batch-replication-policies.html>
- <https://dev.to/aws-builders/use-s3-batch-replication-to-replicate-objects-to-another-account-and-encrypt-with-aws-kms-4efb>
