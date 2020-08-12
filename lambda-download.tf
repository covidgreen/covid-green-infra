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

  aws_parameter_arns = [
    aws_ssm_parameter.db_database.arn,
    aws_ssm_parameter.db_host.arn,
    aws_ssm_parameter.db_port.arn,
    aws_ssm_parameter.db_reader_host.arn,
    aws_ssm_parameter.db_ssl.arn
  ]
  aws_secret_arns                = concat([data.aws_secretsmanager_secret_version.rds.arn, data.aws_secretsmanager_secret_version.rds_read_write.arn], data.aws_secretsmanager_secret_version.interop.*.arn)
  cloudwatch_schedule_expression = var.download_schedule
  config_var_prefix              = local.config_var_prefix
  handler                        = "download.handler"
  log_retention_days             = var.logs_retention_days
  memory_size                    = var.lambda_download_memory_size
  security_group_ids             = [module.lambda_sg.id]
  subnet_ids                     = module.vpc.private_subnets
  tags                           = module.labels.tags
  timeout                        = var.lambda_download_timeout
}
