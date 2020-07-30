# #########################################
# SNS
# #########################################
resource "aws_sns_topic" "daily_registrations_reporter" {
  count = local.lambda_daily_registrations_reporter_count

  name              = "${module.labels.id}-daily-registrations-reporter"
  kms_master_key_id = aws_kms_alias.sns.arn
  tags              = module.labels.tags
}
