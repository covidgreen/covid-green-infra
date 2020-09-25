data "archive_file" "exposures" {
  type        = "zip"
  output_path = "${path.module}/.zip/${module.labels.id}_exposures.zip"
  source_file = "${path.module}/templates/lambda-placeholder.js"
}

data "aws_iam_policy_document" "exposures_policy" {
  statement {
    actions = [
      "s3:*"
    ]
    resources = ["*"]
  }

  statement {
    actions = ["ssm:GetParameter"]
    resources = [
      aws_ssm_parameter.app_bundle_id.arn,
      aws_ssm_parameter.db_database.arn,
      aws_ssm_parameter.db_host.arn,
      aws_ssm_parameter.db_port.arn,
      aws_ssm_parameter.db_ssl.arn,
      aws_ssm_parameter.default_region.arn,
      aws_ssm_parameter.disable_valid_key_check.arn,
      aws_ssm_parameter.native_regions.arn,
      aws_ssm_parameter.s3_assets_bucket.arn,
      aws_ssm_parameter.variance_offset_mins.arn
    ]
  }

  statement {
    actions = ["secretsmanager:GetSecretValue"]
    resources = [
      data.aws_secretsmanager_secret_version.exposures.arn,
      data.aws_secretsmanager_secret_version.rds_read_write.arn
    ]
  }
}

data "aws_iam_policy_document" "exposures_assume_role" {
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

resource "aws_cloudwatch_log_group" "exposures" {
  name              = format("/aws/lambda/%s-exposures", module.labels.id)
  retention_in_days = var.logs_retention_days
  tags              = module.labels.tags
}

resource "aws_iam_policy" "exposures_policy" {
  name   = "${module.labels.id}-lambda-exposures-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.exposures_policy.json
}

resource "aws_iam_role" "exposures" {
  name               = "${module.labels.id}-lambda-exposures"
  assume_role_policy = data.aws_iam_policy_document.exposures_assume_role.json
  tags               = module.labels.tags
}

resource "aws_iam_role_policy_attachment" "exposures_policy" {
  role       = aws_iam_role.exposures.name
  policy_arn = aws_iam_policy.exposures_policy.arn
}

resource "aws_iam_role_policy_attachment" "exposures_aws_managed_policy" {
  role       = aws_iam_role.exposures.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_function" "exposures" {
  # Default is to use the stub file, but we need to cater for S3 bucket file being the source
  filename         = local.lambdas_use_s3_as_source ? null : "${path.module}/.zip/${module.labels.id}_exposures.zip"
  s3_bucket        = local.lambdas_use_s3_as_source ? var.lambdas_custom_s3_bucket : null
  s3_key           = local.lambdas_use_s3_as_source ? var.lambda_exposures_s3_key : null
  source_code_hash = local.lambdas_use_s3_as_source ? "" : data.archive_file.exposures.output_base64sha256

  function_name = "${module.labels.id}-exposures"
  handler       = "exposures.handler"
  layers        = lookup(var.lambda_custom_runtimes, "exposures", "NOT-FOUND") == "NOT-FOUND" ? null : var.lambda_custom_runtimes["exposures"].layers
  memory_size   = var.lambda_exposures_memory_size
  role          = aws_iam_role.exposures.arn
  runtime       = lookup(var.lambda_custom_runtimes, "exposures", "NOT-FOUND") == "NOT-FOUND" ? var.lambda_default_runtime : var.lambda_custom_runtimes["exposures"].runtime
  tags          = module.labels.tags
  timeout       = var.lambda_exposures_timeout

  depends_on = [aws_cloudwatch_log_group.exposures]

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

resource "aws_cloudwatch_event_rule" "exposures_schedule" {
  schedule_expression = var.exposure_schedule
}

resource "aws_cloudwatch_event_target" "exposures_schedule" {
  rule      = aws_cloudwatch_event_rule.exposures_schedule.name
  target_id = "exposures"
  arn       = aws_lambda_function.exposures.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_exposures" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.exposures.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.exposures_schedule.arn
}
