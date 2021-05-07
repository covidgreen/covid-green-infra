# Trigger:
#	SQS queue message
# Resources:
#	KMS
#	Secret manager secrets
#	SNS - naked, no topic for some instances if using AWS to send the SMS
#	SSM parameters
#	SQS queue

module "sms" {
  source = "./modules/lambda"
  enable = true
  name   = format("%s-sms", module.labels.id)

  aws_parameter_arns = [
    aws_ssm_parameter.db_database.arn,
    aws_ssm_parameter.db_host.arn,
    aws_ssm_parameter.db_port.arn,
    aws_ssm_parameter.db_reader_host.arn,
    aws_ssm_parameter.db_ssl.arn,
    aws_ssm_parameter.sms_region.arn,
    aws_ssm_parameter.sms_sender.arn,
    aws_ssm_parameter.sms_template.arn,
    aws_ssm_parameter.sms_url.arn,
    aws_ssm_parameter.time_zone.arn
  ]
  aws_secret_arns                            = concat([data.aws_secretsmanager_secret_version.rds_read_write.arn], data.aws_secretsmanager_secret_version.sms.*.arn)
  config_var_prefix                          = local.config_var_prefix
  enable_sns_publish_for_sms_without_a_topic = var.enable_sms_publishing_with_aws
  handler                                    = "sms.handler"
  kms_reader_arns                            = [aws_kms_key.sqs.arn]
  layers                                     = lookup(var.lambda_custom_runtimes, "sms", "NOT-FOUND") == "NOT-FOUND" ? null : var.lambda_custom_runtimes["sms"].layers
  log_retention_days                         = var.logs_retention_days
  memory_size                                = var.lambda_sms_memory_size
  runtime                                    = lookup(var.lambda_custom_runtimes, "sms", "NOT-FOUND") == "NOT-FOUND" ? var.lambda_default_runtime : var.lambda_custom_runtimes["sms"].runtime
  s3_bucket                                  = var.lambdas_custom_s3_bucket
  s3_key                                     = var.lambda_sms_s3_key
  security_group_ids                         = [module.lambda_sg.id]
  sqs_queue_arns_to_consume_from             = [aws_sqs_queue.sms.arn]
  subnet_ids                                 = module.vpc.private_subnets
  tags                                       = module.labels.tags
  timeout                                    = var.lambda_sms_timeout
}

# Cannot create this in the module, will get a plan issue
resource "aws_lambda_event_source_mapping" "sqs" {
  event_source_arn = aws_sqs_queue.sms.arn
  function_name    = module.sms.function_arn
}
