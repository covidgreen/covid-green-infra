# Trigger:
#	Cloudwatch cron schedule
# Resources:
#	RDS
#	Secret manager secrets
#	SSM parameters

module "cleanup" {
  source = "./modules/lambda"
  enable = true
  name   = format("%s-cleanup", module.labels.id)

  aws_parameter_arns = concat([
    aws_ssm_parameter.db_database.arn,
    aws_ssm_parameter.db_host.arn,
    aws_ssm_parameter.db_port.arn,
    aws_ssm_parameter.db_reader_host.arn,
    aws_ssm_parameter.db_ssl.arn,
    aws_ssm_parameter.security_code_removal_mins.arn,
    aws_ssm_parameter.upload_token_lifetime_mins.arn,
    aws_ssm_parameter.self_isolation_notice_lifetime_mins.arn,
    aws_ssm_parameter.enx_logo_supported.arn,
    aws_ssm_parameter.checkin_summary_enabled.arn
    ],
    aws_ssm_parameter.issue_proxy_url.*.arn
  )
  aws_cloudwatch_metrics         = true
  aws_secret_arns                = concat([data.aws_secretsmanager_secret_version.rds_read_write.arn], data.aws_secretsmanager_secret_version.verify_proxy.*.arn)
  cloudwatch_schedule_expression = var.cleanup_schedule
  config_var_prefix              = local.config_var_prefix
  handler                        = "cleanup.handler"
  layers                         = lookup(var.lambda_custom_runtimes, "cleanup", "NOT-FOUND") == "NOT-FOUND" ? null : var.lambda_custom_runtimes["cleanup"].layers
  log_retention_days             = var.logs_retention_days
  memory_size                    = var.lambda_cleanup_memory_size
  runtime                        = lookup(var.lambda_custom_runtimes, "cleanup", "NOT-FOUND") == "NOT-FOUND" ? var.lambda_default_runtime : var.lambda_custom_runtimes["cleanup"].runtime
  s3_bucket                      = var.lambdas_custom_s3_bucket
  s3_key                         = var.lambda_cleanup_s3_key
  security_group_ids             = [module.lambda_sg.id]
  subnet_ids                     = module.vpc.private_subnets
  tags                           = module.labels.tags
  timeout                        = var.lambda_cleanup_timeout
}
