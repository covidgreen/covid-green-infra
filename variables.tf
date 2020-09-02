# #########################################
# Misc
# #########################################
variable "aws_region" {
  description = "AWS region"
}
variable "dns_profile" {
  description = "AWS profile used to manage Route53 records"
}
variable "environment" {
  description = "Environment i.e. dev"
}
variable "full_name" {
  description = "Fullname, will add as a tag to resources"
}
variable "namespace" {
  description = "Namespace which allows identifying resources i.e. xyz"
}
variable "profile" {
  description = "AWS profile to use"
}

# #########################################
# Log retention
# #########################################
variable "logs_retention_days" {
  description = "Retention in days for the logs"
  default     = 1
}

# #########################################
# APIGateway
# If we want to limit here we can set the throttling_ values - currently -1 = no throttling
# #########################################
variable "api_gateway_account_creation_enabled" {
  description = "APIGateway account creation flag, this is used for CloudWatch logging, should only have one of these per account/region, this flag allows disabling if one already exists"
  default     = true
}
variable "api_gateway_throttling_rate_limit" {
  description = "APIGateway throttling rate limit, default is -1 which does not enforce a limit"
  default     = -1
}
variable "api_gateway_throttling_burst_limit" {
  description = "APIGateway throttling burst limit, default is -1 which does not enforce a limit"
  default     = -1
}

# #########################################
# Cloudtrail
# #########################################
variable "enable_cloudtrail" {
  description = "Enable CloudTrail, default is not to, but non dev envs should enable"
  default     = false
}

# #########################################
# DNS and certificates (Imported/existing certs)
# #########################################
variable "enable_dns" {
  description = "Enable DNS management of Route53 records, in some cases we do not control"
  default     = true
}
variable "enable_certificates" {
  description = "Enable certificate management using AWS Certificates Manage, in some cases we do not control"
  default     = true
}
# Need this if we have enabled_certificates=false and have imported the certificates
variable "api_us_certificate_arn" {
  description = "ECS API certificate used by CloudFront Edge for the APIGateway (us-east-1), we use this if we do not manage the certificates and have to use an imported/existing certificate"
  default     = ""
}
# Need this if we have enabled_certificates=false and have imported the certificates
variable "push_eu_certificate_arn" {
  description = "ECS Push certificate used by the ALB, we use this if we do not manage the certificates and have to use an imported/existing certificate"
  default     = ""
}

# #########################################
# Networking
# #########################################
variable "vpc_cidr" {
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}
variable "private_subnets_cidr" {
  description = "Private subnet CIDRs"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
variable "public_subnets_cidr" {
  description = "Public subnet CIDRs"
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}
variable "database_subnets_cidr" {
  description = "Database subnet CIDRs"
  default     = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}
variable "intra_subnets_cidr" {
  description = "Intra subnet CIDRs"
  default     = ["10.0.31.0/24", "10.0.32.0/24", "10.0.33.0/24"]
}

# #########################################
# RDS Settings
# #########################################
variable "rds_db_name" {
  description = "RDS master DB name"
}
variable "rds_instance_type" {
  description = "RDS instance type"
  default     = "db.t3.medium"
}
variable "rds_cluster_size" {
  description = "RDS cluster size, should be > 1 in non dev environments"
  default     = 1
}
variable "rds_cluster_family" {
  description = "RDS cluster family"
  default     = "aurora-postgresql11"
}
variable "rds_backup_retention" {
  description = "RDS backup retention in days"
  default     = 14
}
variable "rds_enhanced_monitoring_interval" {
  description = "RDS enhanced monitoring metrics interval, the default is 0 which is disabled. Valid Values: 0, 1, 5, 10, 15, 30, 60. These are in seconds."
  default     = 0
}

# #########################################
# ECR Settings
# #########################################
variable "default_ecr_max_image_count" {
  description = "Default ECR image retention count used for purging the ECR repositories"
  default     = 30
}

# #########################################
# R53 Settings
# #########################################
variable "route53_zone" {
  description = "Route53 zone for DNS records"
}
variable "api_dns" {
  description = "DNS for API service"
}
variable "push_dns" {
  description = "DNS for Push service"
}
variable "wildcard_domain" {
  description = "DNS wildcard domain"
}

# #########################################
# Bastion
# #########################################
# This allows preventing bastion access, if this is enabled the default is to have an ASG with desired count = 0
variable "bastion_enabled" {
  description = "Bastion enabled, does not provision the bastion, only allows using a bastion, see the bastion_asg_desired_count variable"
  default     = true
}
variable "bastion_asg_desired_count" {
  description = "Bastion ASG desired count"
  default     = 0
}

# #########################################
# SMS using AWS - used by the SMS lambda
# #########################################
variable "enable_sms_publishing_with_aws" {
  description = "Enable sending SMS via a SNS topic"
  default     = false
}

# #########################################
# WAF
# #########################################
# List of allowed country alpha 2 codes, see https://www.iso.org/obp/ui/#search
# If this is empty then we do not restrict based on country
variable "waf_geo_allowed_countries" {
  description = "List of countries to enable Geo blocking, if empty will be no Geo blocking"
  default     = []
}


# #########################################
# Admins role
# #########################################
variable "admins_role_require_mfa" {
  # Turning this on is fine with the AWS CLI but is tricky with TF and we have multiple accounts in play in some envs
  description = "Require MFA for assuming the admins IAM role"
  default     = false
}

# #########################################
# API & Lambda - Settings & Env vars
# #########################################
variable "api_custom_image" {
  description = "Custom image for the ECS API container, overrides the default ECR repo, assumes we can pull from the repository"
  default     = ""
}
variable "api_image_tag" {
  description = "Image tag for the ECS API container"
  default     = "latest"
}
variable "migrations_custom_image" {
  description = "Custom image for the ECS Migrations container, overrides the default ECR repo, assumes we can pull from the repository"
  default     = ""
}
variable "migrations_image_tag" {
  description = "Image tag for the ECS Migrations container"
  default     = "latest"
}
variable "push_custom_image" {
  description = "Custom image for the ECS Push container, overrides the default ECR repo, assumes we can pull from the repository"
  default     = ""
}
variable "push_image_tag" {
  description = "Image tag for the ECS Push container"
  default     = "latest"
}
variable "api_listening_port" {
  description = "ECS API container port"
  default     = 5000
}
variable "api_listening_protocol" {
  description = "API service ALB protocol"
  default     = "HTTP"
}
variable "api_cors_origin" {
  description = "API service CORS header value"
  default     = "*"
}
variable "health_check_path" {
  description = "Health check path"
  default     = "/healthcheck"
}
variable "health_check_matcher" {
  description = "Health check matcher for ALB health checks"
  default     = "200"
}
variable "health_check_interval" {
  description = "Health check interval for ALB health checks"
  default     = 10
}
variable "health_check_timeout" {
  description = "Health check timeout for ALB health checks"
  default     = 5
}
variable "health_check_healthy_threshold" {
  description = "Health check healthy threshold for ALB health checks"
  default     = 3
}
variable "health_check_unhealthy_threshold" {
  description = "Health check unhealthy threshold for ALB health checks"
  default     = 2
}
variable "api_service_desired_count" {
  description = "ECS API service ASG desired count"
  default     = 1
}
variable "api_services_task_cpu" {
  description = "ECS API service task CPU"
  default     = 256
}
variable "api_services_task_memory" {
  description = "ECS API service task memory"
  default     = 512
}
variable "api_ecs_autoscale_min_instances" {
  description = "ECS API service ASG min count"
  default     = 1
}
variable "api_ecs_autoscale_max_instances" {
  description = "ECS API service ASG max count"
  default     = 2
}
variable "api_cpu_high_threshold" {
  description = "ECS API service ASG scaling CPU high threshold"
  default     = 15
}
variable "api_cpu_low_threshold" {
  description = "ECS API service ASG scaling CPU low threshold"
  default     = 10
}
variable "api_mem_high_threshold" {
  description = "ECS API service ASG scaling memory high threshold"
  default     = 25
}
variable "api_mem_low_threshold" {
  description = "ECS API service ASG scaling memory low threshold"
  default     = 15
}
variable "log_level" {
  description = "Log level for ECS and lambdas"
}
variable "arcgis_url" {
  default = ""
}
variable "daily_registrations_reporter_email_subject" {
  description = "daily-registrations-reporter lambda email subject text"
  default     = ""
}
variable "daily_registrations_reporter_schedule" {
  description = "daily-registrations-reporter lambda CloudWatch schedule"
  default     = ""
}
variable "download_schedule" {
  description = "download lambda CloudWatch schedule"
  default     = "cron(0 * * * ? *)"
}
variable "exposure_schedule" {
  description = "exposures lambda CloudWatch schedule"
}
variable "settings_schedule" {
  description = "settings lambda CloudWatch schedule"
}
variable "upload_schedule" {
  description = "upload lambda CloudWatch schedule"
  default     = "cron(0 * * * ? *)"
}
variable "refresh_token_expiry" {
  default = "10y"
}
variable "code_charset" {
  default = "0123456789"
}
variable "code_length" {
  default = "6"
}
variable "code_lifetime_mins" {
}
variable "token_lifetime_mins" {
}
variable "upload_token_lifetime_mins" {
  default = "1440"
}
variable "metrics_config" {
  default = "{ \"CONTACT_UPLOAD\": 60, \"CHECK_IN\": 60, \"FORGET\": 60, \"TOKEN_RENEWAL\": 60, \"CALLBACK_OPTIN\": 60, \"DAILY_ACTIVE_TRACE\": 60, \"CONTACT_NOTIFICATION\": 60, \"LOG_ERROR\": 60, \"CALLBACK_REQUEST\": 60 }"
}
variable "verify_rate_limit_secs" {
}
variable "push_listening_port" {
  description = "ECS Push container port"
  default     = 6000
}
variable "push_listening_protocol" {
  description = "Push service ALB protocol"
  default     = "HTTP"
}
variable "push_services_task_cpu" {
  description = "ECS Push service task CPU"
  default     = 256
}
variable "push_services_task_memory" {
  description = "ECS Push service task memory"
  default     = 512
}
variable "push_ecs_autoscale_min_instances" {
  description = "ECS Push service ASG min count"
  default     = 1
}
variable "push_ecs_autoscale_max_instances" {
  description = "ECS Push service ASG max count"
  default     = 1
}
variable "push_cpu_high_threshold" {
  description = "ECS Push service ASG scaling CPU high threshold"
  default     = 15
}
variable "push_cpu_low_threshold" {
  description = "ECS Push service ASG scaling CPU low threshold"
  default     = 10
}
variable "push_mem_high_threshold" {
  description = "ECS Push service ASG scaling memory high threshold"
  default     = 25
}
variable "push_mem_low_threshold" {
  description = "ECS Push service ASG scaling memory low threshold"
  default     = 15
}
variable "push_service_desired_count" {
  description = "ECS Push service ASG desired count"
  default     = 1
}
variable "push_allowed_ips" {
  description = "ECS Push service ALB allowed ingress CIDRs"
  default     = ["0.0.0.0/0"]
}
variable "app_bundle_id" {
  default = ""
}
variable "enable_callback" {
  default = "true"
}
variable "enable_callback_email_notifications" {
  default = "false"
}
variable "enable_check_in" {
  default = "true"
}
variable "enable_legacy_settings" {
  default = "false"
}
variable "enable_metrics" {
  default = "true"
}
variable "certificate_audience" {
  default = ""
}
variable "default_country_code" {
  default = ""
}
variable "default_region" {
  default = ""
}
variable "lambda_authorizer_memory_size" {
  description = "authorizer lambda memory size"
  default     = 512 # Since this is on the hot path and we get faster CPUs with higher memory
}
variable "lambda_authorizer_s3_key" {
  description = "authorizer lambda S3 key if using - file path"
  default     = ""
}
variable "lambda_authorizer_timeout" {
  description = "authorizer lambda timeout"
  default     = 15
}
variable "lambda_callback_memory_size" {
  description = "callback lambda memory size"
  default     = 128
}
variable "lambda_callback_s3_key" {
  description = "callback lambda S3 key if using - file path"
  default     = ""
}
variable "lambda_callback_timeout" {
  description = "callback lambda timeout"
  default     = 15
}
variable "lambda_cso_memory_size" {
  description = "cso lambda memory size"
  default     = 3008
}
variable "lambda_cso_s3_key" {
  description = "cso lambda S3 key if using - file path"
  default     = ""
}
variable "lambda_cso_timeout" {
  description = "cso lambda timeout"
  default     = 900
}
variable "lambda_daily_registrations_reporter_memory_size" {
  description = "daily-registrations-reporter lambda memory size"
  default     = 128
}
variable "lambda_daily_registrations_reporter_s3_key" {
  description = "daily-registrations-reporter lambda S3 key if using - file path"
  default     = ""
}
variable "lambda_daily_registrations_reporter_timeout" {
  description = "daily-registrations-reporter lambda timeout"
  default     = 15
}
variable "lambda_download_memory_size" {
  description = "download lambda memory size"
  default     = 128
}
variable "lambda_download_s3_key" {
  description = "download lambda S3 key if using - file path"
  default     = ""
}
variable "lambda_download_timeout" {
  description = "download lambda timeout"
  default     = 15
}
variable "lambda_exposures_memory_size" {
  description = "exposures lambda memory size"
  default     = 128
}
variable "lambda_exposures_s3_key" {
  description = "exposures lambda S3 key if using - file path"
  default     = ""
}
variable "lambda_exposures_timeout" {
  description = "exposures lambda timeout"
  default     = 15
}
variable "lambda_provisioned_concurrencies" {
  description = "Map of lambdas to use provisioned concurrency i.e. { \"authorizer\" : 300 }"
  default     = {}
}
variable "lambda_settings_memory_size" {
  description = "settings lambda memory size"
  default     = 128
}
variable "lambda_settings_s3_key" {
  description = "settings lambda S3 key if using - file path"
  default     = ""
}
variable "lambda_settings_timeout" {
  description = "settings lambda timeout"
  default     = 15
}
variable "lambda_sms_memory_size" {
  description = "sms lambda memory size"
  default     = 128
}
variable "lambda_sms_s3_key" {
  description = "sms lambda S3 key if using - file path"
  default     = ""
}
variable "lambda_sms_timeout" {
  description = "sms lambda timeout"
  default     = 15
}
variable "lambda_stats_memory_size" {
  description = "stats lambda memory size"
  default     = 256
}
variable "lambda_stats_s3_key" {
  description = "stats lambda S3 key if using - file path"
  default     = ""
}
variable "lambda_stats_timeout" {
  description = "stats lambda timeout"
  default     = 120
}
variable "lambda_token_memory_size" {
  description = "token lambda memory size"
  default     = 128
}
variable "lambda_token_s3_key" {
  description = "token lambda S3 key if using - file path"
  default     = ""
}
variable "lambda_token_timeout" {
  description = "token lambda timeout"
  default     = 15
}
variable "lambda_upload_memory_size" {
  description = "upload lambda memory size"
  default     = 128
}
variable "lambda_upload_s3_key" {
  description = "upload lambda S3 key if using - file path"
  default     = ""
}
variable "lambda_upload_timeout" {
  description = "upload lambda timeout"
  default     = 15
}
variable "lambdas_custom_s3_bucket" {
  description = "Lambdas custom S3 bucket, overrides the default local file usage, assumes we can get content from the bucket as this module does not manage this bucket"
  default     = ""
}
variable "native_regions" {
  default = ""
}
variable "optional_parameters_to_include" {
  description = "List of optional parameters to include"
  default     = []
}
variable "optional_secrets_to_include" {
  description = "List of optional secrets to include"
  default     = []
}
variable "optional_lambdas_to_include" {
  description = "List of optional lambdas to include"
  default     = []
}
variable "sms_template" {
  description = "SMS message template"
  default     = ""
}
variable "sms_sender" {
  description = "SMS message sender identifier"
  default     = ""
}
variable "sms_region" {
  description = "AWS region to use when sending SMS messages"
  default     = ""
}
variable "time_zone" {
  description = "Time zone used for localisation of endpoints that are rate limited to once per day, for example /check-in"
  default     = "UTC"
}
