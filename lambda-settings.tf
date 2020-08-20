data "archive_file" "settings" {
  type        = "zip"
  output_path = "${path.module}/.zip/${module.labels.id}_settings.zip"
  source_file = "${path.module}/templates/lambda-placeholder.js"
}

data "aws_iam_policy_document" "settings_policy" {
  statement {
    actions = [
      "s3:*"
    ]
    resources = ["*"]
  }

  statement {
    actions = ["ssm:GetParameter"]
    resources = [
      aws_ssm_parameter.db_database.arn,
      aws_ssm_parameter.db_host.arn,
      aws_ssm_parameter.db_port.arn,
      aws_ssm_parameter.db_ssl.arn,
      aws_ssm_parameter.s3_assets_bucket.arn
    ]
  }

  statement {
    actions = ["secretsmanager:GetSecretValue"]
    resources = [
      data.aws_secretsmanager_secret_version.rds_read_write.arn
    ]
  }
}

data "aws_iam_policy_document" "settings_assume_role" {
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

resource "aws_cloudwatch_log_group" "settings" {
  name              = format("/aws/lambda/%s-settings", module.labels.id)
  retention_in_days = var.logs_retention_days
  tags              = module.labels.tags
}

resource "aws_iam_policy" "settings_policy" {
  name   = "${module.labels.id}-lambda-settings-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.settings_policy.json
}

resource "aws_iam_role" "settings" {
  name               = "${module.labels.id}-lambda-settings"
  assume_role_policy = data.aws_iam_policy_document.settings_assume_role.json
  tags               = module.labels.tags
}

resource "aws_iam_role_policy_attachment" "settings_policy" {
  role       = aws_iam_role.settings.name
  policy_arn = aws_iam_policy.settings_policy.arn
}

resource "aws_iam_role_policy_attachment" "settings_aws_managed_policy" {
  role       = aws_iam_role.settings.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_function" "settings" {
  filename         = "${path.module}/.zip/${module.labels.id}_settings.zip"
  function_name    = "${module.labels.id}-settings"
  source_code_hash = data.archive_file.settings.output_base64sha256
  role             = aws_iam_role.settings.arn
  runtime          = "nodejs12.x"
  handler          = "settings.handler"
  memory_size      = var.lambda_settings_memory_size
  timeout          = var.lambda_settings_timeout
  tags             = module.labels.tags

  depends_on = [aws_cloudwatch_log_group.settings]

  vpc_config {
    security_group_ids = [module.lambda_sg.id]
    subnet_ids         = module.vpc.private_subnets
  }

  environment {
    variables = {
      CONFIG_VAR_PREFIX = local.config_var_prefix,
      NODE_ENV          = "production"
    }
  }

  lifecycle {
    ignore_changes = [
      source_code_hash,
    ]
  }
}

resource "aws_cloudwatch_event_rule" "settings_schedule" {
  schedule_expression = var.settings_schedule
}

resource "aws_cloudwatch_event_target" "settings_schedule" {
  rule      = aws_cloudwatch_event_rule.settings_schedule.name
  target_id = "settings"
  arn       = aws_lambda_function.settings.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_settings" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.settings.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.settings_schedule.arn
}
