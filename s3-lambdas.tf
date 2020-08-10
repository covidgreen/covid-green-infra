resource "aws_s3_bucket" "lambdas" {
  bucket = module.labels.id
  acl    = "private"
  tags   = module.labels.tags

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "lambdas" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
