data "archive_file" "cso" {
  type        = "zip"
  output_path = "${path.module}/.zip/${module.labels.id}_cso.zip"
  source_file = "${path.module}/templates/lambda-placeholder.js"
}

data "aws_iam_policy_document" "cso_policy" {
  statement {
    actions   = ["s3:*"]
    resources = ["*"]
  }

  statement {
    actions = ["ssm:GetParameter"]
    resources = [
      aws_ssm_parameter.db_database.arn,
      aws_ssm_parameter.db_host.arn,
      aws_ssm_parameter.db_port.arn,
      aws_ssm_parameter.db_ssl.arn
    ]
  }

  statement {
    actions = ["secretsmanager:GetSecretValue"]
    resources = concat(
      [data.aws_secretsmanager_secret_version.rds_read_write.arn],
      data.aws_secretsmanager_secret_version.cso.*.arn
    )
  }
}

data "aws_iam_policy_document" "cso_assume_role" {
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

resource "aws_cloudwatch_log_group" "cso" {
  count             = local.lambda_cso_count
  name              = format("/aws/lambda/%s-cso", module.labels.id)
  retention_in_days = var.logs_retention_days
  tags              = module.labels.tags
}

resource "aws_iam_policy" "cso_policy" {
  count  = local.lambda_cso_count
  name   = "${module.labels.id}-lambda-cso-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.cso_policy.json
}

resource "aws_iam_role" "cso" {
  count              = local.lambda_cso_count
  name               = "${module.labels.id}-lambda-cso"
  assume_role_policy = data.aws_iam_policy_document.cso_assume_role.json
  tags               = module.labels.tags
}

resource "aws_iam_role_policy_attachment" "cso_policy" {
  count      = local.lambda_cso_count
  role       = aws_iam_role.cso[0].name
  policy_arn = aws_iam_policy.cso_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "cso_aws_managed_policy" {
  count      = local.lambda_cso_count
  role       = aws_iam_role.cso[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_function" "cso" {
  count = local.lambda_cso_count

  # Default is to use the stub file, but we need to cater for S3 bucket file being the source
  filename         = local.lambdas_use_s3_as_source ? null : "${path.module}/.zip/${module.labels.id}_cso.zip"
  s3_bucket        = local.lambdas_use_s3_as_source ? var.lambdas_custom_s3_bucket : null
  s3_key           = local.lambdas_use_s3_as_source ? var.lambda_cso_s3_key : null
  source_code_hash = local.lambdas_use_s3_as_source ? "" : data.archive_file.cso.output_base64sha256

  function_name = "${module.labels.id}-cso"
  handler       = "cso.handler"
  layers        = lookup(var.lambda_custom_runtimes, "cso", "NOT-FOUND") == "NOT-FOUND" ? null : var.lambda_custom_runtimes["cso"].layers
  memory_size   = var.lambda_cso_memory_size
  role          = aws_iam_role.cso[0].arn
  runtime       = lookup(var.lambda_custom_runtimes, "cso", "NOT-FOUND") == "NOT-FOUND" ? var.lambda_default_runtime : var.lambda_custom_runtimes["cso"].runtime
  tags          = module.labels.tags
  timeout       = var.lambda_cso_timeout

  depends_on = [aws_cloudwatch_log_group.cso]

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

resource "aws_cloudwatch_event_rule" "cso_schedule" {
  count               = local.lambda_cso_count
  schedule_expression = var.cso_schedule
}

resource "aws_cloudwatch_event_target" "cso_schedule" {
  count     = local.lambda_cso_count
  rule      = aws_cloudwatch_event_rule.cso_schedule[0].name
  target_id = "cso"
  arn       = aws_lambda_function.cso[0].arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_cso" {
  count         = local.lambda_cso_count
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cso[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cso_schedule[0].arn
}
