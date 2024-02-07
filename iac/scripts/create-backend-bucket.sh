#!/bin/bash

bucket_name="narwhal-delivery-iac-swf"
region="us-gov-west-1"

# Check if the bucket exists
if aws s3 ls "s3://${bucket_name}" 2>&1 | grep -q 'NoSuchBucket'; then
    echo "Bucket does not exist. Creating bucket: ${bucket_name} in region ${region}"

    # Create the bucket
    if aws s3api create-bucket --bucket "${bucket_name}" --region "${region}" --create-bucket-configuration LocationConstraint="${region}" > /dev/null; then
        echo "Bucket created successfully."
    else
        echo "Failed to create bucket."
        exit 1
    fi
else
    echo "Bucket already exists: ${bucket_name}"
fi
