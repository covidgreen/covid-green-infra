resource "aws_s3_bucket" "assets" {
  bucket = module.labels.id
  acl    = "private"
  tags   = module.labels.tags

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

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_object" "admin_ui_directory" {
    bucket = aws_s3_bucket.assets.id
    key    = "admin-ui/"
    source = "/dev/null"
}