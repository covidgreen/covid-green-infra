# #########################################
# Module variables
# #########################################
# See "Managed policies" at the bottom of https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html
# Going to default to allow VPC access as we do connect to RDS for most
# Bare min you want is the AWSLambdaBasicExecutionRole policy for CloudWatch logs
variable "aws_managed_policy_arn_to_attach" {
  default = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

variable "aws_parameter_arns" {
  default = []
}

variable "aws_secret_arns" {
  default = []
}

variable "aws_cloudwatch_metrics" {
  default = false
}

variable "cloudwatch_schedule_expression" {
  default = ""
}

variable "config_var_prefix" {
  default = ""
}

variable "enable" {
  default = true
}

# Where we are not using a topic and sending SMS messages
# See https://docs.logonbox.com/app/manpage/en/article/495939
# See https://blog.shikisoft.com/send-sms-with-sns-aws-lambda-python/
variable "enable_sns_publish_for_sms_without_a_topic" {
  default = false
}

variable "handler" {
  default = ""
}

variable "kms_reader_arns" {
  default = []
}

variable "kms_writer_arns" {
  default = []
}

# If using a custom runtime i.e. runtime = "provided", set this to a list of layers
variable "layers" {
  default = null
}

variable "log_retention_days" {
  default = 1
}

variable "memory_size" {
  default = 128
}

variable "name" {
  default = ""
}

variable "runtime" {
  default = "nodejs12.x"
}

variable "security_group_ids" {
  default = []
}

# Default is not to use it
variable "s3_bucket" {
  default = ""
}

variable "s3_bucket_arns_to_read_from" {
  default = []
}

variable "s3_bucket_arns_to_write_to" {
  default = []
}

variable "s3_key" {
  default = ""
}

variable "ses_send_emails_from_email_addresses" {
  default = []
}

variable "sns_topic_arns_to_consume_from" {
  default = []
}

variable "sns_topic_arns_to_publish_to" {
  default = []
}

variable "sqs_queue_arns_to_consume_from" {
  default = []
}

variable "sqs_queue_arns_to_publish_to" {
  default = []
}

variable "subnet_ids" {
  default = []
}

variable "tags" {
  default = {}
}

variable "timeout" {
  default = 15
}

variable "concurrency" {
  default = -1
}

# #########################################
# Module content
# #########################################
locals {
  aws_managed_policy_arn_to_attach_count = var.enable && var.aws_managed_policy_arn_to_attach != "" ? 1 : 0
  enable_cloudwatch_schedule_count       = var.enable && var.cloudwatch_schedule_expression != "" ? 1 : 0
  enable_count                           = var.enable ? 1 : 0
  use_s3_as_source                       = var.s3_bucket != "" && var.s3_key != ""
}

data "archive_file" "this" {
  output_path = format("%s/.zip/%s.zip", path.module, var.name)
  source_file = format("%s/templates/lambda-placeholder.js", path.module)
  type        = "zip"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "this" {
  # See links above on the var
  dynamic statement {
    for_each = var.enable_sns_publish_for_sms_without_a_topic ? { 1 : 1 } : {}
    content {
      actions = [
        "sns:Publish",
        "sns:SetSMSAttributes",
      ]
      resources = ["*"]
    }
  }

  # See links above on the var - assumes this will not prevent access to explict topics below
  dynamic statement {
    for_each = var.enable_sns_publish_for_sms_without_a_topic ? { 1 : 1 } : {}
    content {
      actions   = ["sns:Publish"]
      effect    = "Deny"
      resources = ["arn:aws:sns:*:*:*"]
    }
  }

  dynamic statement {
    for_each = length(var.kms_reader_arns) > 0 ? { 1 : 1 } : {}
    content {
      actions = [
        "kms:GenerateDataKey",
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:GetPublicKey"
      ]
      resources = var.kms_reader_arns
    }
  }

  dynamic statement {
    for_each = length(var.kms_writer_arns) > 0 ? { 1 : 1 } : {}
    content {
      actions = [
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:Encrypt",
        "kms:GenerateDataKey",
        "kms:GenerateDataKey*",
        "kms:GetPublicKey",
        "kms:ReEncrypt*"
      ]
      resources = var.kms_writer_arns
    }
  }

  dynamic statement {
    for_each = length(var.aws_parameter_arns) > 0 ? { 1 : 1 } : {}
    content {
      actions   = ["ssm:GetParameter"]
      resources = var.aws_parameter_arns
    }
  }

  dynamic statement {
    for_each = length(var.aws_secret_arns) > 0 ? { 1 : 1 } : {}
    content {
      actions   = ["secretsmanager:GetSecretValue"]
      resources = var.aws_secret_arns
    }
  }

  dynamic statement {
    for_each = var.aws_cloudwatch_metrics ? { 1 : 1 } : {}
    content {
      actions   = ["cloudwatch:GetMetricsData"]
      resources = ["*"]
    }
  }

  # See https://docs.aws.amazon.com/IAM/latest/UserGuide/list_amazonses.html
  # See https://docs.aws.amazon.com/ses/latest/DeveloperGuide/control-user-access.html
  dynamic statement {
    for_each = length(var.ses_send_emails_from_email_addresses) > 0 ? { 1 : 1 } : {}
    content {
      actions = ["ses:SendEmail", "ses:SendRawEmail"]
      condition {
        test     = "StringLike"
        values   = var.ses_send_emails_from_email_addresses
        variable = "ses:FromAddress"
      }
      resources = ["*"]
    }
  }

  # See https://docs.aws.amazon.com/IAM/latest/UserGuide/list_amazons3.html
  # Here one statement can cover the reads and writers
  dynamic statement {
    for_each = length(var.s3_bucket_arns_to_read_from) + length(var.s3_bucket_arns_to_write_to) > 0 ? { 1 : 1 } : {}
    content {
      actions   = ["s3:ListBucket"]
      resources = concat(var.s3_bucket_arns_to_read_from, var.s3_bucket_arns_to_write_to)
    }
  }

  # See https://docs.aws.amazon.com/IAM/latest/UserGuide/list_amazons3.html
  dynamic statement {
    for_each = length(var.s3_bucket_arns_to_read_from) > 0 ? { 1 : 1 } : {}
    content {
      actions   = ["s3:GetObject", "s3:GetObjectVersion"]
      resources = [for bucket in var.s3_bucket_arns_to_read_from : format("%s/*", bucket)]
    }
  }

  # See https://docs.aws.amazon.com/IAM/latest/UserGuide/list_amazons3.html
  dynamic statement {
    for_each = length(var.s3_bucket_arns_to_write_to) > 0 ? { 1 : 1 } : {}
    content {
      actions   = ["s3:DeleteObject", "s3:GetObject", "s3:GetObjectVersion", "s3:PutObject"]
      resources = [for bucket in var.s3_bucket_arns_to_write_to : format("%s/*", bucket)]
    }
  }

  # See https://docs.aws.amazon.com/IAM/latest/UserGuide/list_amazonsns.html
  dynamic statement {
    for_each = length(var.sns_topic_arns_to_consume_from) > 0 ? { 1 : 1 } : {}
    content {
      actions   = ["sns:Subscribe"]
      resources = var.sns_topic_arns_to_consume_from
    }
  }

  # See https://docs.aws.amazon.com/IAM/latest/UserGuide/list_amazonsns.html
  dynamic statement {
    for_each = length(var.sns_topic_arns_to_publish_to) > 0 ? { 1 : 1 } : {}
    content {
      actions   = ["sns:Publish"]
      resources = var.sns_topic_arns_to_publish_to
    }
  }

  # See https://docs.aws.amazon.com/IAM/latest/UserGuide/list_amazonsqs.html
  dynamic statement {
    for_each = length(var.sqs_queue_arns_to_consume_from) > 0 ? { 1 : 1 } : {}
    content {
      actions   = ["sqs:DeleteMessage", "sqs:GetQueueAttributes", "sqs:ReceiveMessage"]
      resources = var.sqs_queue_arns_to_consume_from
    }
  }

  # See https://docs.aws.amazon.com/IAM/latest/UserGuide/list_amazonsqs.html
  dynamic statement {
    for_each = length(var.sqs_queue_arns_to_publish_to) > 0 ? { 1 : 1 } : {}
    content {
      actions   = ["sqs:SendMessage"]
      resources = var.sqs_queue_arns_to_publish_to
    }
  }
}

resource "aws_cloudwatch_log_group" "this" {
  count = local.enable_count

  name              = format("/aws/lambda/%s", var.name)
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_iam_policy" "this" {
  count = local.enable_count

  name   = format("%s-lambda-policy", var.name)
  path   = "/"
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role" "this" {
  count = local.enable_count

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  name               = format("%s-lambda", var.name)
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "aws_managed_policy" {
  count = local.aws_managed_policy_arn_to_attach_count

  policy_arn = var.aws_managed_policy_arn_to_attach
  role       = aws_iam_role.this[0].name
}

resource "aws_iam_role_policy_attachment" "this" {
  count = local.enable_count

  policy_arn = aws_iam_policy.this[0].arn
  role       = aws_iam_role.this[0].name
}

resource "aws_lambda_function" "this" {
  count = local.enable_count

  filename         = local.use_s3_as_source ? null : format("%s/.zip/%s.zip", path.module, var.name)
  s3_bucket        = local.use_s3_as_source ? var.s3_bucket : null
  s3_key           = local.use_s3_as_source ? var.s3_key : null
  source_code_hash = local.use_s3_as_source ? null : data.archive_file.this.output_base64sha256

  function_name = var.name
  handler       = var.handler
  layers        = var.layers
  memory_size   = var.memory_size
  role          = aws_iam_role.this[0].arn
  runtime       = var.runtime
  tags          = var.tags
  timeout       = var.timeout
  
  depends_on = [aws_cloudwatch_log_group.this]

  # See https://docs.aws.amazon.com/lambda/latest/dg/invocation-scaling.html
  # Use default `concurrency` value for no limit
  reserved_concurrent_executions = var.concurrency
  
  environment {
    variables = {
      CONFIG_VAR_PREFIX = var.config_var_prefix,
      NODE_ENV          = "production"
    }
  }

  lifecycle {
    ignore_changes = [
      source_code_hash,
      filename
    ]
  }

  # See https://www.terraform.io/docs/providers/aws/r/lambda_function.html#vpc_config
  # Leave both security_group_ids and subnet_ids empty for this to have no effect
  vpc_config {
    security_group_ids = var.security_group_ids
    subnet_ids         = var.subnet_ids
  }
}

resource "aws_cloudwatch_event_rule" "this" {
  count = local.enable_cloudwatch_schedule_count

  schedule_expression = var.cloudwatch_schedule_expression
}

resource "aws_cloudwatch_event_target" "this" {
  count = local.enable_cloudwatch_schedule_count

  rule      = aws_cloudwatch_event_rule.this[0].name
  target_id = var.name
  arn       = aws_lambda_function.this[0].arn
}

resource "aws_lambda_permission" "this" {
  count = local.enable_cloudwatch_schedule_count

  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this[0].arn
}


# #########################################
# Module outputs
# #########################################
output "function_arn" {
  value = join("", aws_lambda_function.this.*.arn)
}

output "function_name" {
  value = join("", aws_lambda_function.this.*.function_name)
}
