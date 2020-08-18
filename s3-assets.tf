resource "aws_s3_bucket" "assets" {
  bucket = module.labels.id
  acl    = "private"
  tags   = module.labels.tags

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_object" "agency_logo" {
  bucket = aws_s3_bucket.assets.id
  key    = var.agency_logo_s3_key
  source = local.agency_logo_path
  etag   = filemd5(local.agency_logo_path)
}
