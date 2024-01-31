#!/bin/bash

dynamodb_table="narwhal-delivery-iac-swf-terraform-state-lock"
region="us-gov-west-1"

check_table_exists() {
    aws dynamodb describe-table --table-name "$dynamodb_table" --region "$region" &> /dev/null
    return $?
}

if check_table_exists; then
    echo "DynamoDB table already exists: ${dynamodb_table}"
else
    echo "DynamoDB table does not exist. Creating table: ${dynamodb_table} in region ${region}"

    # Create the DynamoDB table for Terraform state locking with on-demand capacity
    if aws dynamodb create-table \
        --table-name "${dynamodb_table}" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region "$region" &> /dev/null; then
        echo "DynamoDB table created successfully."
    else
        echo "Failed to create DynamoDB table."
        exit 1
    fi
fi
