# Trigger:
#	Cloudwatch cron schedule
# Resources:
#	RDS
#	Secret manager secrets
#	SSM parameters

module "download" {
  source = "./modules/lambda"
  enable = contains(var.optional_lambdas_to_include, "download")
  name   = format("%s-download", module.labels.id)

  aws_parameter_arns = concat([
    aws_ssm_parameter.db_database.arn,
    aws_ssm_parameter.db_host.arn,
    aws_ssm_parameter.db_port.arn,
    aws_ssm_parameter.db_reader_host.arn,
    aws_ssm_parameter.db_ssl.arn,
    aws_ssm_parameter.time_zone.arn
    ],
    aws_ssm_parameter.interop_origin.*.arn
  )

  aws_secret_arns                = concat([data.aws_secretsmanager_secret_version.rds_read_write.arn], data.aws_secretsmanager_secret_version.interop.*.arn)
  cloudwatch_schedule_expression = var.download_schedule
  config_var_prefix              = local.config_var_prefix
  handler                        = "download.handler"
  layers                         = lookup(var.lambda_custom_runtimes, "download", "NOT-FOUND") == "NOT-FOUND" ? null : var.lambda_custom_runtimes["download"].layers
  log_retention_days             = var.logs_retention_days
  memory_size                    = var.lambda_download_memory_size
  runtime                        = lookup(var.lambda_custom_runtimes, "download", "NOT-FOUND") == "NOT-FOUND" ? var.lambda_default_runtime : var.lambda_custom_runtimes["download"].runtime
  s3_bucket                      = var.lambdas_custom_s3_bucket
  s3_key                         = var.lambda_download_s3_key
  security_group_ids             = [module.lambda_sg.id]
  subnet_ids                     = module.vpc.private_subnets
  tags                           = module.labels.tags
  timeout                        = var.lambda_download_timeout
}
