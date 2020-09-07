# #########################################
# CloudWatch
# #########################################
resource "aws_cloudwatch_log_group" "sns_sms_logs" {
  count = var.enable_sms_publishing_with_aws ? 1 : 0

  name              = format("/aws/lambda/%s-sns-sms-logs", module.labels.id)
  retention_in_days = var.logs_retention_days
  tags              = module.labels.tags
}

# #########################################
# IAM
# #########################################
data "aws_iam_policy_document" "sns_sms_logs_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutMetricFilter",
      "logs:PutRetentionPolicy"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "sns_sms_logs_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "sns.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_policy" "sns_sms_policy" {
  count = var.enable_sms_publishing_with_aws ? 1 : 0

  name   = "${module.labels.id}-sns-sms-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.sns_sms_logs_policy.json
}

resource "aws_iam_role" "sns_sms_role" {
  count = var.enable_sms_publishing_with_aws ? 1 : 0

  name               = "${module.labels.id}-sns-sms"
  assume_role_policy = data.aws_iam_policy_document.sns_sms_logs_role.json
  tags               = module.labels.tags
}

resource "aws_iam_role_policy_attachment" "sns_sms_policy" {
  count = var.enable_sms_publishing_with_aws ? 1 : 0

  role       = aws_iam_role.sns_sms_role[0].name
  policy_arn = aws_iam_policy.sns_sms_policy[0].arn
}

# #########################################
# SNS
# #########################################
resource "aws_sns_sms_preferences" "update_sms_prefs" {
  count = var.enable_sms_publishing_with_aws ? 1 : 0

  delivery_status_iam_role_arn          = aws_iam_role.sns_sms_role[0].arn
  delivery_status_success_sampling_rate = var.sms_delivery_status_success_sampling_rate
  monthly_spend_limit                   = var.sms_monthly_spend_limit
}

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