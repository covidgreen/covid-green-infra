# #########################################
# Locals
# #########################################
locals {
  # Pick one, using the var if it is set, else failback to the one we manage
  alb_push_certificate_arn = coalesce(var.push_eu_certificate_arn, join("", aws_acm_certificate.wildcard_cert.*.arn))

  # Based on flag
  bastion_enabled_count = var.bastion_enabled ? 1 : 0

  # Cloudtrail S3 bucket name
  cloudtrail_s3_bucket_name = format("%s-cloudtrail", module.labels.id)

  # Will be used as a prefix for AWS parameters and secrets
  config_var_prefix = "${module.labels.id}-"

  # ECS image values
  ecs_api_image        = format("%s:%s", coalesce(var.api_custom_image, aws_ecr_repository.api.repository_url), var.api_image_tag)
  ecs_migrations_image = format("%s:%s", coalesce(var.migrations_custom_image, aws_ecr_repository.migrations.repository_url), var.migrations_image_tag)
  ecs_push_image       = format("%s:%s", coalesce(var.push_custom_image, aws_ecr_repository.push.repository_url), var.push_image_tag)

  # Based on flag
  enable_certificates_count = var.enable_certificates ? 1 : 0

  # Based on flag
  enable_cloudtrail_count = var.enable_cloudtrail ? 1 : 0

  # Based on flag
  enable_dns_count = var.enable_dns ? 1 : 0

  # PENDING: Revisit this
  # Need to only create one of these for an account/region
  # Logic is all the dev envs are in a single account, and assumes all the other envs are in a dedicated account/region
  gateway_api_account_count = (var.environment == "dev" && var.namespace == "fight-together") || var.environment != "dev" ? 1 : 0

  # Pick one, using the var if it is set, else failback to the one we manage
  gateway_api_certificate_arn = coalesce(var.api_us_certificate_arn, join("", aws_acm_certificate.wildcard_cert_us.*.arn))

  # Based on either of DNS enabled OR (We have an api_dns AND and api_us_certificate_arn)
  gateway_api_domain_name_count = var.enable_dns || (var.api_dns != "" && var.api_us_certificate_arn != "") ? 1 : 0

  # Lambda creation counts
  lambda_cso_count                          = contains(var.optional_lambdas_to_include, "cso") ? 1 : 0
  lambda_daily_registrations_reporter_count = contains(var.optional_lambdas_to_include, "daily-registrations-reporter") ? 1 : 0
  lambda_download_count                     = contains(var.optional_lambdas_to_include, "download") ? 1 : 0
  lambda_upload_count                       = contains(var.optional_lambdas_to_include, "upload") ? 1 : 0

  # RDS enhanced monitoring count
  rds_enhanced_monitoring_enabled_count = var.rds_enhanced_monitoring_interval > 0 ? 1 : 0

  # WAF geo blocking - optional
  waf_geo_blocking_count = length(var.waf_geo_allowed_countries) > 0 ? 1 : 0

  # This is required as we use the count as toggle:
  cloudtrail_log_group_name = join(" ", aws_cloudwatch_log_group.cloudtrail.*.name)
  # Cloudtrail log stream related:
  cloudtrail_log_stream_arn_pattern = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:${local.cloudtrail_log_group_name}:log-stream:${data.aws_caller_identity.current.account_id}_CloudTrail_${var.aws_region}*"
}
