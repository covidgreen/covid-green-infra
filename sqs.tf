# #########################################
# SQS
# See for KMS usage https://github.com/xpolb01/terraform-encrypted-sqs-sns/blob/master/sqs.tf
# #########################################
resource "aws_sqs_queue" "callback" {
  name              = "${module.labels.id}-callback"
  kms_master_key_id = aws_kms_alias.sqs.arn
  tags              = module.labels.tags
}

resource "aws_sqs_queue" "sms" {
  name              = "${module.labels.id}-sms"
  kms_master_key_id = aws_kms_alias.sqs.arn
  tags              = module.labels.tags
}
