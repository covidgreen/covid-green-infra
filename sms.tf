# #########################################
# CloudWatch
# #########################################
resource "aws_cloudwatch_log_group" "sns_sms_logs" {
  for_each = toset(local.sns_sms_cloudwatch_log_group_names)

  provider = aws.sms

  name              = each.key
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
      identifiers = [
        "sns.amazonaws.com"
      ]
      type = "Service"
    }
  }
}

resource "aws_iam_policy" "sns_sms_policy" {
  count = local.enable_sms_publishing_with_aws_count

  name   = "${module.labels.id}-sns-sms-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.sns_sms_logs_policy.json
}

resource "aws_iam_role" "sns_sms_role" {
  count = local.enable_sms_publishing_with_aws_count

  assume_role_policy = data.aws_iam_policy_document.sns_sms_logs_role.json
  name               = "${module.labels.id}-sns-sms"
  tags               = module.labels.tags
}

resource "aws_iam_role_policy_attachment" "sns_sms_policy" {
  count = local.enable_sms_publishing_with_aws_count

  policy_arn = aws_iam_policy.sns_sms_policy[0].arn
  role       = aws_iam_role.sns_sms_role[0].name
}

# #########################################
# SNS
# #########################################
resource "aws_sns_sms_preferences" "update_sms_prefs" {
  count = local.enable_sms_publishing_with_aws_count

  provider = aws.sms

  default_sender_id                     = var.sms_sender
  default_sms_type                      = var.sms_type
  delivery_status_iam_role_arn          = aws_iam_role.sns_sms_role[0].arn
  delivery_status_success_sampling_rate = var.sms_delivery_status_success_sampling_rate
  monthly_spend_limit                   = var.sms_monthly_spend_limit
}
