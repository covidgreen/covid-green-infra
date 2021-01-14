# Trigger:
#	Cloudwatch cron schedule
# Resources:
#	RDS
#	Secret manager secrets
#	SSM parameters

module "upload" {
  source = "./modules/lambda"
  enable = contains(var.optional_lambdas_to_include, "upload")
  name   = format("%s-upload", module.labels.id)

  aws_parameter_arns = concat([
    aws_ssm_parameter.db_database.arn,
    aws_ssm_parameter.db_host.arn,
    aws_ssm_parameter.db_port.arn,
    aws_ssm_parameter.db_reader_host.arn,
    aws_ssm_parameter.db_ssl.arn,
    aws_ssm_parameter.time_zone.arn,
    aws_ssm_parameter.variance_offset_mins.arn
    ],
    aws_ssm_parameter.interop_origin.*.arn
  )
  aws_secret_arns                = concat([data.aws_secretsmanager_secret_version.rds_read_write.arn], data.aws_secretsmanager_secret_version.interop.*.arn)
  cloudwatch_schedule_expression = var.upload_schedule
  config_var_prefix              = local.config_var_prefix
  handler                        = "upload.handler"
  layers                         = lookup(var.lambda_custom_runtimes, "upload", "NOT-FOUND") == "NOT-FOUND" ? null : var.lambda_custom_runtimes["upload"].layers
  log_retention_days             = var.logs_retention_days
  memory_size                    = var.lambda_upload_memory_size
  runtime                        = lookup(var.lambda_custom_runtimes, "upload", "NOT-FOUND") == "NOT-FOUND" ? var.lambda_default_runtime : var.lambda_custom_runtimes["upload"].runtime
  s3_bucket                      = var.lambdas_custom_s3_bucket
  s3_key                         = var.lambda_upload_s3_key
  security_group_ids             = [module.lambda_sg.id]
  subnet_ids                     = module.vpc.private_subnets
  tags                           = module.labels.tags
  timeout                        = var.lambda_upload_timeout
}
