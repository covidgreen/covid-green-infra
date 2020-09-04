data "archive_file" "token" {
  type        = "zip"
  output_path = "${path.module}/.zip/${module.labels.id}_token.zip"
  source_file = "${path.module}/templates/lambda-placeholder.js"
}

data "aws_iam_policy_document" "token_policy" {
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
    resources = [
      data.aws_secretsmanager_secret_version.jwt.arn,
      data.aws_secretsmanager_secret_version.rds_read_write.arn
    ]
  }
}

data "aws_iam_policy_document" "token_assume_role" {
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

resource "aws_cloudwatch_log_group" "token" {
  name              = format("/aws/lambda/%s-token", module.labels.id)
  retention_in_days = var.logs_retention_days
  tags              = module.labels.tags
}

resource "aws_iam_policy" "token_policy" {
  name   = "${module.labels.id}-lambda-token-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.token_policy.json
}

resource "aws_iam_role" "token" {
  name               = "${module.labels.id}-lambda-token"
  assume_role_policy = data.aws_iam_policy_document.token_assume_role.json
  tags               = module.labels.tags
}

resource "aws_iam_role_policy_attachment" "token_policy" {
  role       = aws_iam_role.token.name
  policy_arn = aws_iam_policy.token_policy.arn
}

resource "aws_iam_role_policy_attachment" "token_aws_managed_policy" {
  role       = aws_iam_role.token.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_function" "token" {
  # Default is to use the stub file, but we need to cater for S3 bucket file being the source
  filename         = local.lambdas_use_s3_as_source ? null : "${path.module}/.zip/${module.labels.id}_token.zip"
  s3_bucket        = local.lambdas_use_s3_as_source ? var.lambdas_custom_s3_bucket : null
  s3_key           = local.lambdas_use_s3_as_source ? var.lambda_token_s3_key : null
  source_code_hash = local.lambdas_use_s3_as_source ? "" : data.archive_file.token.output_base64sha256

  function_name = "${module.labels.id}-token"
  handler       = "token.handler"
  layers        = lookup(var.lambda_custom_runtimes, "token", "NOT-FOUND") == "NOT-FOUND" ? null : var.lambda_custom_runtimes["token"].layers
  memory_size   = var.lambda_token_memory_size
  role          = aws_iam_role.token.arn
  runtime       = lookup(var.lambda_custom_runtimes, "token", "NOT-FOUND") == "NOT-FOUND" ? var.lambda_default_runtime : var.lambda_custom_runtimes["token"].runtime
  tags          = module.labels.tags
  timeout       = var.lambda_token_timeout

  depends_on = [aws_cloudwatch_log_group.token]

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
