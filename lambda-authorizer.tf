data "archive_file" "authorizer" {
  type        = "zip"
  output_path = "${path.module}/.zip/${module.labels.id}_authorizer.zip"
  source_file = "${path.module}/templates/lambda-placeholder.js"
}

data "aws_iam_policy_document" "authorizer_policy" {
  statement {
    actions = [
      "lambda:InvokeFunction",
      "secretsmanager:GetSecretValue"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "authorizer_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "apigateway.amazonaws.com",
        "lambda.amazonaws.com"
      ]
    }
  }
}

resource "aws_cloudwatch_log_group" "authorizer" {
  name              = format("/aws/lambda/%s-authorizer", module.labels.id)
  retention_in_days = var.logs_retention_days
  tags              = module.labels.tags
}

resource "aws_iam_policy" "authorizer_policy" {
  name   = "${module.labels.id}-lambda-authorizer-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.authorizer_policy.json
}

resource "aws_iam_role" "authorizer" {
  name               = "${module.labels.id}-lambda-authorizer"
  assume_role_policy = data.aws_iam_policy_document.authorizer_assume_role.json
  tags               = module.labels.tags
}

resource "aws_iam_role_policy_attachment" "authorizer_policy" {
  role       = aws_iam_role.authorizer.name
  policy_arn = aws_iam_policy.authorizer_policy.arn
}

resource "aws_iam_role_policy_attachment" "authorizer_logs" {
  role       = aws_iam_role.authorizer.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "authorizer" {
  # Default is to use the stub file, but we need to cater for S3 bucket file being the source
  filename         = local.lambdas_use_s3_as_source ? null : "${path.module}/.zip/${module.labels.id}_authorizer.zip"
  s3_bucket        = local.lambdas_use_s3_as_source ? var.lambdas_custom_s3_bucket : null
  s3_key           = local.lambdas_use_s3_as_source ? var.lambda_authorizer_s3_key : null
  source_code_hash = local.lambdas_use_s3_as_source ? "" : data.archive_file.authorizer.output_base64sha256

  function_name = "${module.labels.id}-authorizer"
  handler       = "authorizer.handler"
  layers        = lookup(var.lambda_custom_runtimes, "authorizer", "NOT-FOUND") == "NOT-FOUND" ? null : var.lambda_custom_runtimes["authorizer"].layers
  memory_size   = var.lambda_authorizer_memory_size
  role          = aws_iam_role.authorizer.arn
  runtime       = lookup(var.lambda_custom_runtimes, "authorizer", "NOT-FOUND") == "NOT-FOUND" ? var.lambda_default_runtime : var.lambda_custom_runtimes["authorizer"].runtime
  tags          = module.labels.tags
  timeout       = var.lambda_authorizer_timeout

  depends_on = [aws_cloudwatch_log_group.authorizer]

  environment {
    variables = {
      CONFIG_VAR_PREFIX = local.config_var_prefix,
      NODE_ENV          = "production"
      JWT_SECRET        = jsondecode(data.aws_secretsmanager_secret_version.jwt.secret_string)["key"]
    }
  }

  lifecycle {
    ignore_changes = [
      source_code_hash,
      filename
    ]
  }
}

# Since we cannot use $LATEST in the alias the CD should update this alias using: aws lambda update-alias
resource "aws_lambda_alias" "authorizer_live" {
  count = lookup(var.lambda_provisioned_concurrencies, "authorizer", "NOT-FOUND") != "NOT-FOUND" ? 1 : 0

  name             = "${module.labels.id}-authorizer-live" # Could have used a short name here
  description      = format("%s-authorizer live", module.labels.id)
  function_name    = aws_lambda_function.authorizer.arn
  function_version = aws_lambda_function.authorizer.version # Note we cannot use $LATEST
}

resource "aws_lambda_provisioned_concurrency_config" "authorizer_live" {
  count = lookup(var.lambda_provisioned_concurrencies, "authorizer", "NOT-FOUND") != "NOT-FOUND" ? 1 : 0

  function_name                     = aws_lambda_function.authorizer.function_name
  provisioned_concurrent_executions = var.lambda_provisioned_concurrencies["authorizer"]
  qualifier                         = aws_lambda_alias.authorizer_live[0].name
}
