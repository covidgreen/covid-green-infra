resource "aws_lambda_event_source_mapping" "sqs_lambda_mapping" {
  event_source_arn = aws_sqs_queue.self_isolation.arn
  function_name    = module.self_isolation_notices.function_arn
}

module "self_isolation_notices" {
  source = "./modules/lambda"
  name   = format("%s-%s", module.labels.id, "self-isolation-notices")

  handler                        = "notices.handler"
  sqs_queue_arns_to_consume_from = [aws_sqs_queue.self_isolation.arn]
  sqs_queue_arns_to_publish_to   = [aws_sqs_queue.self_isolation.arn]
  aws_secret_arns                = concat([data.aws_secretsmanager_secret_version.rds_read_write.arn], data.aws_secretsmanager_secret_version.notice.*.arn)
  config_var_prefix              = format("%s-", module.labels.id)
  aws_parameter_arns = [
    aws_ssm_parameter.notices_sqs_arn.arn,
    aws_ssm_parameter.enable_self_isolation_notices.arn,
    aws_ssm_parameter.db_host.arn,
    aws_ssm_parameter.db_port.arn,
    aws_ssm_parameter.db_ssl.arn,
    aws_ssm_parameter.db_database.arn,
    aws_ssm_parameter.self_isolation_notices_url.arn
  ]
  kms_writer_arns = [aws_kms_key.sqs.arn]

  #Memory and timeout
  memory_size = var.lambda_self_isolation_memory_size
  timeout     = var.lambda_self_isolation_timeout
  log_retention_days = var.logs_retention_days
  security_group_ids = [module.lambda_sg.id]
  subnet_ids         = module.vpc.private_subnets

}
