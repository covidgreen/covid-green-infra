output "admins_role_arn" {
  description = "ARN of the role used for admins"
  value       = aws_iam_role.admins.arn
}

output "api_aws_dns" {
  value = join("", aws_api_gateway_domain_name.main.*.cloudfront_domain_name)
}
output "ci_user_name" {
  value = aws_iam_user.ci_user.name
}
output "cloudtrail_log_group_name" {
  value = join(" ", aws_cloudwatch_log_group.cloudtrail.*.name)
}

output "cognito_user_pool_domain" {
  value = "${join("", aws_route53_record.auth_cognito_A_record.*.fqdn)}"

  #value = format("https://%s", aws_route53_record.auth_cognito_A_record[0].fqdn)
}

output "cognito_user_pool_endpoint" {
  value = aws_cognito_user_pool.admin_user_pool.endpoint
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.admin_user_pool.id
}
output "default_tags" {
  value = module.labels.tags
}

output "ecs_cluster_api_service_name" {
  value = aws_ecs_service.api.name
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.services.name
}

output "ecs_cluster_push_service_name" {
  value = aws_ecs_service.push.name
}

output "intra_subnets" {
  value = module.vpc.intra_subnets
}

output "lambda_authorizer_name" {
  value = aws_lambda_function.authorizer.function_name
}

output "lambda_authorizer_timeout" {
  value = aws_lambda_function.authorizer.timeout
}

output "lambda_names" {
  value = concat(
    # Standard lambdas
    [aws_lambda_function.authorizer.function_name,
      aws_lambda_function.callback.function_name,
      aws_lambda_function.exposures.function_name,
      aws_lambda_function.settings.function_name,
      module.sms.function_name,
      aws_lambda_function.stats.function_name,
    aws_lambda_function.token.function_name],

    # Optional lambdas
    [for name in var.optional_lambdas_to_include : format("%s-%s", module.labels.id, name)]
  )
}

output "lambda_sg_id" {
  value = module.lambda_sg.id
}

output "lb_api_arn" {
  value = aws_lb.api.arn
}

output "lb_api_arn_suffix" {
  value = aws_lb.api.arn_suffix
}

output "lb_push_arn" {
  value = aws_lb.push.arn
}

output "lb_push_arn_suffix" {
  value = aws_lb.push.arn_suffix
}

output "prefix_id" {
  value = module.labels.id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "push_aws_dns" {
  value = aws_lb.push.dns_name
}

output "rds_cluster_arn" {
  value = module.rds_cluster_aurora_postgres.arn
}

output "rds_cluster_identifier" {
  value = module.rds_cluster_aurora_postgres.cluster_identifier
}

output "rds_endpoint" {
  value = module.rds_cluster_aurora_postgres.endpoint
}

output "rds_reader_endpoint" {
  value = module.rds_cluster_aurora_postgres.reader_endpoint
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "waf_acl_metric_name" {
  value = aws_wafregional_web_acl.acl.metric_name
}

output "waf_acl_name" {
  value = aws_wafregional_web_acl.acl.name
}
