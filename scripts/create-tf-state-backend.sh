#!/bin/bash
# Assumes you have already configured your AWS_PROFILE or env vars and have privs to create resources
#
# Being optimistic that the S3 bucket is available
#
# Note this is not idempotent, would make more sense to just use TF without a backend to create these resources
#
# Usage is
#	./create-tf-state-backend.sh eu-west-1 xyz-dev-terraform-store xyz-dev-terraform-lock
#	./create-tf-state-backend.sh eu-west-2 xyz-prod-terraform-store xyz-prod-terraform-lock
#	./create-tf-state-backend.sh eu-west-1 xyz-dev-terraform-store xyz-dev-terraform-lock
#
set -eou pipefail
: ${1?AWS region is required}
: ${2?S3 bucket name is required}
: ${3?DynamoDB table name is required}

aws_region=${1}
s3_bucket_name=${2}
dynamodb_table_name=${3}
location_constraint="LocationConstraint=${aws_region}"

if [ "$aws_region" = "us-east-1" ]; then
    # us-east-1 is a special case per AWS.
    location_constraint=""
fi

# S3 bucket
# Create bucket
aws s3api create-bucket --bucket ${s3_bucket_name} \
    --region ${aws_region} \
    --create-bucket-configuration $location_constraint
# Encrypt bucket
aws s3api put-bucket-encryption \
    --bucket ${s3_bucket_name} \
    --server-side-encryption-configuration='{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
# Apply versioning
aws s3api put-bucket-versioning --bucket ${s3_bucket_name} --versioning-configuration Status=Enabled
# Apply block public access config
aws s3api put-public-access-block \
    --bucket ${s3_bucket_name} \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" \


# DynamoDb table
# Create table
aws dynamodb create-table \
    --table-name ${dynamodb_table_name} \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST
