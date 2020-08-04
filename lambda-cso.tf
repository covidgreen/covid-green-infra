data "archive_file" "cso" {
  type        = "zip"
  output_path = "${path.module}/.zip/${module.labels.id}_cso.zip"
  source_file = "${path.module}/templates/lambda-placeholder.js"
}

data "aws_iam_policy_document" "cso_policy" {
  statement {
    actions = [
      "s3:*",
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DetachNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "secretsmanager:GetSecretValue",
      "ssm:GetParameter"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "cso_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
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

resource "aws_iam_role_policy_attachment" "cso_logs" {
  count      = local.lambda_cso_count
  role       = aws_iam_role.cso[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_s3_bucket_object" "cso_s3_file" {
  bucket = aws_s3_bucket.lambdas.id
  key    = "lambdas/${module.labels.id}_cso.zip"
  source = "${path.module}/.zip/${module.labels.id}_cso.zip"
}

resource "aws_lambda_function" "cso" {
  count            = local.lambda_cso_count
  s3_bucket        = (var.cso_lambda_s3_bucket != "" ? var.cso_lambda_s3_bucket : aws_s3_bucket_object.cso_s3_file.bucket)
  s3_key           = (var.cso_lambda_s3_key != "" ? var.cso_lambda_s3_key : aws_s3_bucket_object.cso_s3_file.key)
  function_name    = "${module.labels.id}-cso"
  source_code_hash = (var.cso_lambda_s3_key != "" ? "" : data.archive_file.cso.output_base64sha256)
  role             = aws_iam_role.cso[0].arn
  runtime          = "nodejs10.x"
  handler          = "cso.handler"
  memory_size      = 3008 # PENDING: This will need to be calculated after a few runs
  timeout          = 900  # PENDING: this will need to be calculated after a few runs
  tags             = module.labels.tags

  depends_on = [aws_cloudwatch_log_group.cso]

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

resource "aws_cloudwatch_event_rule" "cso_schedule" {
  count               = local.lambda_cso_count
  schedule_expression = "cron(0 0 * * ? *)"
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
