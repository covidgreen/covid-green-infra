# #########################################
# SQS
# See for KMS usage https://github.com/xpolb01/terraform-encrypted-sqs-sns/blob/master/sqs.tf
# #########################################
resource "aws_sqs_queue" "callback" {
  name              = "${module.labels.id}-callback"
  kms_master_key_id = aws_kms_alias.sqs.arn
  tags              = module.labels.tags
  # AWS recommends setting vis_timeout to _at least_ lambda_timeout * 6
  # https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html#events-sqs-queueconfig
  visibility_timeout_seconds = var.lambda_callback_timeout * 6
}

resource "aws_sqs_queue" "sms" {
  name              = "${module.labels.id}-sms"
  kms_master_key_id = aws_kms_alias.sqs.arn
  tags              = module.labels.tags
  # AWS recommends setting vis_timeout to _at least_ lambda_timeout * 6
  # https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html#events-sqs-queueconfig
  visibility_timeout_seconds = var.lambda_sms_timeout * 6
}

resource "aws_sqs_queue" "self_isolation" {
  name              = format("%s-%s", module.labels.id, "self-isolation-notices")
  kms_master_key_id = aws_kms_alias.sqs.arn
  tags              = module.labels.tags
  # AWS recommends setting vis_timeout to _at least_ lambda_timeout * 6
  # https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html#events-sqs-queueconfig
  visibility_timeout_seconds = var.lambda_self_isolation_timeout * 6
}
