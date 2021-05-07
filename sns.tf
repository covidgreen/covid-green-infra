resource "aws_sns_topic" "callback_email_notifications" {
  count = local.enable_callback_email_notifications_count

  name              = "${module.labels.id}-callback-email-notifications"
  kms_master_key_id = aws_kms_alias.sns.arn
  tags              = module.labels.tags
}

resource "aws_sns_topic" "daily_registrations_reporter" {
  count = local.lambda_daily_registrations_reporter_count

  name              = "${module.labels.id}-daily-registrations-reporter"
  kms_master_key_id = aws_kms_alias.sns.arn
  tags              = module.labels.tags
}
