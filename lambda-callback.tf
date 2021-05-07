data "archive_file" "callback" {
  type        = "zip"
  output_path = "${path.module}/.zip/${module.labels.id}_callback.zip"
  source_file = "${path.module}/templates/lambda-placeholder.js"
}

data "aws_iam_policy_document" "callback_policy" {
  statement {
    actions = [
      "s3:*",
      "sqs:*"
    ]
    resources = ["*"]
  }

  statement {
    actions = ["ssm:GetParameter"]
    resources = concat(
      [
        aws_ssm_parameter.callback_url.arn,
        aws_ssm_parameter.db_database.arn,
        aws_ssm_parameter.db_host.arn,
        aws_ssm_parameter.db_port.arn,
        aws_ssm_parameter.db_ssl.arn,
        aws_ssm_parameter.time_zone.arn
      ],
      aws_ssm_parameter.callback_email_notifications_sns_arn.*.arn
    )
  }

  statement {
    actions = ["secretsmanager:GetSecretValue"]
    resources = concat(
      [data.aws_secretsmanager_secret_version.rds_read_write.arn],
      data.aws_secretsmanager_secret_version.cct.*.arn
    )
  }

  statement {
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:GenerateDataKey*",
      "kms:GetPublicKey",
      "kms:ReEncrypt*"
    ]
    resources = [
      aws_kms_key.sns.arn,
      aws_kms_key.sqs.arn
    ]
  }

  dynamic statement {
    for_each = local.enable_callback_email_notifications_count > 0 ? { 1 : 1 } : {}
    content {
      actions   = ["sns:Publish"]
      resources = aws_sns_topic.callback_email_notifications.*.arn
    }
  }
}

data "aws_iam_policy_document" "callback_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

resource "aws_cloudwatch_log_group" "callback" {
  name              = format("/aws/lambda/%s-callback", module.labels.id)
  retention_in_days = var.logs_retention_days
  tags              = module.labels.tags
}

resource "aws_iam_policy" "callback_policy" {
  name   = "${module.labels.id}-lambda-callback-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.callback_policy.json
}

resource "aws_iam_role" "callback" {
  name               = "${module.labels.id}-lambda-callback"
  assume_role_policy = data.aws_iam_policy_document.callback_assume_role.json
  tags               = module.labels.tags
}

resource "aws_iam_role_policy_attachment" "callback_policy" {
  role       = aws_iam_role.callback.name
  policy_arn = aws_iam_policy.callback_policy.arn
}

resource "aws_iam_role_policy_attachment" "callback_aws_managed_policy" {
  role       = aws_iam_role.callback.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_function" "callback" {
  # Default is to use the stub file, but we need to cater for S3 bucket file being the source
  filename         = local.lambdas_use_s3_as_source ? null : "${path.module}/.zip/${module.labels.id}_callback.zip"
  s3_bucket        = local.lambdas_use_s3_as_source ? var.lambdas_custom_s3_bucket : null
  s3_key           = local.lambdas_use_s3_as_source ? var.lambda_callback_s3_key : null
  source_code_hash = local.lambdas_use_s3_as_source ? "" : data.archive_file.callback.output_base64sha256

  function_name = "${module.labels.id}-callback"
  handler       = "callback.handler"
  layers        = lookup(var.lambda_custom_runtimes, "callback", "NOT-FOUND") == "NOT-FOUND" ? null : var.lambda_custom_runtimes["callback"].layers
  memory_size   = var.lambda_callback_memory_size
  role          = aws_iam_role.callback.arn
  runtime       = lookup(var.lambda_custom_runtimes, "callback", "NOT-FOUND") == "NOT-FOUND" ? var.lambda_default_runtime : var.lambda_custom_runtimes["callback"].runtime
  tags          = module.labels.tags
  timeout       = var.lambda_callback_timeout

  depends_on = [aws_cloudwatch_log_group.callback]

  environment {
    variables = {
      CONFIG_VAR_PREFIX = local.config_var_prefix,
      NODE_ENV          = "production"
    }
  }

  lifecycle {
    ignore_changes = [
      source_code_hash,
      filename
    ]
  }

  vpc_config {
    security_group_ids = [module.lambda_sg.id]
    subnet_ids         = module.vpc.private_subnets
  }
}

resource "aws_lambda_event_source_mapping" "callback" {
  event_source_arn = aws_sqs_queue.callback.arn
  function_name    = aws_lambda_function.callback.arn
}
