# #########################################
# Cloudtrail
# #########################################
resource "aws_cloudtrail" "cloudtrail" {
  count                         = local.enable_cloudtrail_count
  enable_log_file_validation    = true
  include_global_service_events = true
  is_multi_region_trail         = true
  name                          = format("%s-%s", module.labels.id, "cloudtrail")
  s3_bucket_name                = aws_s3_bucket.cloudtrail[0].id
  tags                          = module.labels.tags
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_cloudwatch_role[0].arn
  cloud_watch_logs_group_arn    = aws_cloudwatch_log_group.cloudtrail[0].arn
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  count             = local.enable_cloudtrail_count
  name              = format("%s%s", "/aws/cloudtrail/", module.labels.id)
  retention_in_days = var.logs_retention_days
}

resource "aws_iam_role" "cloudtrail_cloudwatch_role" {
  count              = local.enable_cloudtrail_count
  name               = format("%s-%s", module.labels.id, "cloudtrail-cloudwatch")
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "cloudtrail_cloudwatch_policy" {
  count  = local.enable_cloudtrail_count
  name   = format("%s-%s", module.labels.id, "cloudtrail-cloudwatch")
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {

      "Sid": "AWSCloudTrailCreateLogStream20201707",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream"
      ],
      "Resource": [
        "${local.cloudtrail_log_stream_arn_pattern}"
      ]

    },
    {
      "Sid": "AWSCloudTrailPutLogEvents20201707",
      "Effect": "Allow",
      "Action": [
        "logs:PutLogEvents"
      ],
      "Resource": [
        "${local.cloudtrail_log_stream_arn_pattern}"
      ]
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "cloudwatch_cloudtrail_attachment" {
  count      = local.enable_cloudtrail_count
  role       = aws_iam_role.cloudtrail_cloudwatch_role[0].name
  policy_arn = aws_iam_policy.cloudtrail_cloudwatch_policy[0].arn
}

resource "aws_s3_bucket" "cloudtrail" {
  count  = local.enable_cloudtrail_count
  bucket = local.cloudtrail_s3_bucket_name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "s3:GetBucketAcl",
      "Effect": "Allow",
      "Principal": { "Service": "cloudtrail.amazonaws.com" },
      "Resource": "arn:aws:s3:::${local.cloudtrail_s3_bucket_name}",
      "Sid": "AWSCloudTrailAclCheck"
    },
    {
      "Action": "s3:PutObject",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      },
      "Effect": "Allow",
      "Principal": { "Service": "cloudtrail.amazonaws.com" },
      "Resource": "arn:aws:s3:::${local.cloudtrail_s3_bucket_name}/*",
      "Sid": "AWSCloudTrailWrite"
    }
  ]
}
EOF

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "default" {
  count                   = local.enable_cloudtrail_count
  bucket                  = aws_s3_bucket.cloudtrail[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}
