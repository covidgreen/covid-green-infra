# Trigger:
#	Cloudwatch cron schedule
# Resources:
#	KMS
#	RDS
#	Secret manager secrets
#	SNS topic
#	SSM parameters

module "daily_registrations_reporter" {
  source = "./modules/lambda"
  enable = contains(var.optional_lambdas_to_include, "daily-registrations-reporter")
  name   = format("%s-daily-registrations-reporter", module.labels.id)

  aws_parameter_arns = concat([
    aws_ssm_parameter.db_database.arn,
    aws_ssm_parameter.db_host.arn,
    aws_ssm_parameter.db_port.arn,
    aws_ssm_parameter.db_reader_host.arn,
    aws_ssm_parameter.db_ssl.arn
    ],
    aws_ssm_parameter.daily_registrations_reporter_email_subject.*.arn,
    aws_ssm_parameter.daily_registrations_reporter_sns_arn.*.arn
  )
  aws_secret_arns                = [data.aws_secretsmanager_secret_version.rds_read_write.arn]
  cloudwatch_schedule_expression = var.daily_registrations_reporter_schedule
  config_var_prefix              = local.config_var_prefix
  handler                        = "reporter.handler"
  kms_writer_arns                = [aws_kms_key.sns.arn]
  layers                         = lookup(var.lambda_custom_runtimes, "daily-registrations-reporter", "NOT-FOUND") == "NOT-FOUND" ? null : var.lambda_custom_runtimes["daily-registrations-reporter"].layers
  log_retention_days             = var.logs_retention_days
  memory_size                    = var.lambda_daily_registrations_reporter_memory_size
  runtime                        = lookup(var.lambda_custom_runtimes, "daily-registrations-reporter", "NOT-FOUND") == "NOT-FOUND" ? var.lambda_default_runtime : var.lambda_custom_runtimes["daily-registrations-reporter"].runtime
  s3_bucket                      = var.lambdas_custom_s3_bucket
  s3_key                         = var.lambda_daily_registrations_reporter_s3_key
  security_group_ids             = [module.lambda_sg.id]
  sns_topic_arns_to_publish_to   = aws_sns_topic.daily_registrations_reporter.*.arn
  subnet_ids                     = module.vpc.private_subnets
  tags                           = module.labels.tags
  timeout                        = var.lambda_daily_registrations_reporter_timeout
}
