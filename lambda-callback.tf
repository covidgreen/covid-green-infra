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
    resources = [
      aws_ssm_parameter.callback_url.arn,
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
      data.aws_secretsmanager_secret_version.cct.*.arn
    )
  }

  statement {
    actions = ["kms:*"]
    resources = [
      aws_kms_key.sqs.arn
    ]
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
  filename         = "${path.module}/.zip/${module.labels.id}_callback.zip"
  function_name    = "${module.labels.id}-callback"
  source_code_hash = data.archive_file.callback.output_base64sha256
  role             = aws_iam_role.callback.arn
  runtime          = "nodejs12.x"
  handler          = "callback.handler"
  memory_size      = var.lambda_callback_memory_size
  timeout          = var.lambda_callback_timeout
  tags             = module.labels.tags

  depends_on = [aws_cloudwatch_log_group.callback]

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

resource "aws_lambda_event_source_mapping" "callback" {
  event_source_arn = aws_sqs_queue.callback.arn
  function_name    = aws_lambda_function.callback.arn
}
