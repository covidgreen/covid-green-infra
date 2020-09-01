# #########################################
# Misc
# #########################################
variable "aws_region" {}
variable "dns_profile" {}
variable "environment" {}
variable "full_name" {}
variable "namespace" {}
variable "profile" {}


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
variable "api_gateway_throttling_rate_limit" {
  default = -1
}
variable "api_gateway_throttling_burst_limit" {
  default = -1
}

# #########################################
# Cloudtrail
# #########################################
variable "enable_cloudtrail" {
  default = false
}

# #########################################
# DNS and certificates (Imported/existing certs)
# #########################################
variable "enable_dns" {
  default = true
}
variable "enable_certificates" {
  default = true
}
# Need this if we have enabled_certificates=false and have imported the certificates
variable "api_us_certificate_arn" {
  default = ""
}
# Need this if we have enabled_certificates=false and have imported the certificates
variable "push_eu_certificate_arn" {
  default = ""
}

# #########################################
# Networking
# #########################################
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "private_subnets_cidr" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
variable "public_subnets_cidr" {
  default = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}
variable "database_subnets_cidr" {
  default = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}
variable "intra_subnets_cidr" {
  default = ["10.0.31.0/24", "10.0.32.0/24", "10.0.33.0/24"]
}

# #########################################
# RDS Settings
# #########################################
variable "rds_db_name" {}
variable "rds_instance_type" {
  default = "db.t3.medium"
}
variable "rds_cluster_size" {
  default = 1
}
variable "rds_cluster_family" {
  default = "aurora-postgresql11"
}
variable "rds_backup_retention" {
  default = 14
}
# Enhanced monitoring metrics, the default is 0 which is disabled. Valid Values: 0, 1, 5, 10, 15, 30, 60. These are in seconds.
variable "rds_enhanced_monitoring_interval" {
  default = 0
}

# #########################################
# ECR Settings
# #########################################
variable "default_ecr_max_image_count" {
  default = 30
}

# #########################################
# R53 Settings
# #########################################
variable "route53_zone" {}
variable "api_dns" {}
variable "push_dns" {}
variable "wildcard_domain" {}

# #########################################
# Bastion
# #########################################
# This allows preventing bastion access, if this is enabled the default is to have an ASG with desired count = 0
variable "bastion_enabled" {
  default = true
}
variable "bastion_asg_desired_count" {
  default = 0
}

# #########################################
# SMS using AWS - used by the SMS lambda
# #########################################
variable "enable_sms_publishing_with_aws" {
  default = false
}

# #########################################
# WAF
# #########################################
# List of allowed country alpha 2 codes, see https://www.iso.org/obp/ui/#search
# If this is empty then we do not restrict based on country
variable "waf_geo_allowed_countries" {
  default = []
}


# #########################################
# Admins role
# #########################################
variable "admins_role_require_mfa" {
  # Turning this on is fine with the AWS CLI but is tricky with TF and we have multiple accounts in play in some envs
  default = false
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
  default = 5000
}
variable "api_listening_protocol" {
  default = "HTTP"
}
variable "api_cors_origin" {
  default = "*"
}
variable "health_check_path" {
  default = "/healthcheck"
}
variable "health_check_matcher" {
  default = "200"
}
variable "health_check_interval" {
  default = 10
}
variable "health_check_timeout" {
  default = 5
}
variable "health_check_healthy_threshold" {
  default = 3
}
variable "health_check_unhealthy_threshold" {
  default = 2
}
variable "api_service_desired_count" {
  default = 1
}
variable "api_services_task_cpu" {
  default = 256
}
variable "api_services_task_memory" {
  default = 512
}
variable "api_ecs_autoscale_min_instances" {
  default = 1
}
variable "api_ecs_autoscale_max_instances" {
  default = 2
}
variable "api_cpu_high_threshold" {
  default = 15
}
variable "api_cpu_low_threshold" {
  default = 10
}
variable "api_mem_high_threshold" {
  default = 25
}
variable "api_mem_low_threshold" {
  default = 15
}
variable "log_level" {}
variable "arcgis_url" {
  default = ""
}
variable "daily_registrations_reporter_email_subject" {
  default = ""
}
variable "daily_registrations_reporter_schedule" {
  default = ""
}
variable "download_schedule" {
  default = "cron(0 * * * ? *)"
}
variable "exposure_schedule" {}
variable "settings_schedule" {}
variable "upload_schedule" {
  default = "cron(0 * * * ? *)"
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
variable "code_lifetime_mins" {}
variable "token_lifetime_mins" {}
variable "upload_token_lifetime_mins" {
  default = "1440"
}
variable "metrics_config" {
  default = "{ \"CONTACT_UPLOAD\": 60, \"CHECK_IN\": 60, \"FORGET\": 60, \"TOKEN_RENEWAL\": 60, \"CALLBACK_OPTIN\": 60, \"DAILY_ACTIVE_TRACE\": 60, \"CONTACT_NOTIFICATION\": 60, \"LOG_ERROR\": 60, \"CALLBACK_REQUEST\": 60 }"
}
variable "verify_rate_limit_secs" {}
variable "push_listening_port" {
  default = 6000
}
variable "push_listening_protocol" {
  default = "HTTP"
}
variable "push_services_task_cpu" {
  default = 256
}
variable "push_services_task_memory" {
  default = 512
}
variable "push_ecs_autoscale_min_instances" {
  default = 1
}
variable "push_ecs_autoscale_max_instances" {
  default = 1
}
variable "push_cpu_high_threshold" {
  default = 15
}
variable "push_cpu_low_threshold" {
  default = 10
}
variable "push_mem_high_threshold" {
  default = 25
}
variable "push_mem_low_threshold" {
  default = 15
}
variable "push_service_desired_count" {
  default = 1
}
variable "push_allowed_ips" {
  default = ["0.0.0.0/0"]
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
  default = 512 # Since this is on the hot path and we get faster CPUs with higher memory
}
variable "lambda_authorizer_s3_key" {
  default = ""
}
variable "lambda_authorizer_timeout" {
  default = 15
}
variable "lambda_callback_memory_size" {
  default = 128
}
variable "lambda_callback_s3_key" {
  default = ""
}
variable "lambda_callback_timeout" {
  default = 15
}
variable "lambda_cso_memory_size" {
  default = 3008
}
variable "lambda_cso_s3_key" {
  default = ""
}
variable "lambda_cso_timeout" {
  default = 900
}
variable "lambda_daily_registrations_reporter_memory_size" {
  default = 128
}
variable "lambda_daily_registrations_reporter_s3_key" {
  default = ""
}
variable "lambda_daily_registrations_reporter_timeout" {
  default = 15
}
variable "lambda_download_memory_size" {
  default = 128
}
variable "lambda_download_s3_key" {
  default = ""
}
variable "lambda_download_timeout" {
  default = 15
}
variable "lambda_exposures_memory_size" {
  default = 128
}
variable "lambda_exposures_s3_key" {
  default = ""
}
variable "lambda_exposures_timeout" {
  default = 15
}
variable "lambda_provisioned_concurrencies" {
  default = {}
}
variable "lambda_settings_memory_size" {
  default = 128
}
variable "lambda_settings_s3_key" {
  default = ""
}
variable "lambda_settings_timeout" {
  default = 15
}
variable "lambda_sms_memory_size" {
  default = 128
}
variable "lambda_sms_s3_key" {
  default = ""
}
variable "lambda_sms_timeout" {
  default = 15
}
variable "lambda_stats_memory_size" {
  default = 256
}
variable "lambda_stats_s3_key" {
  default = ""
}
variable "lambda_stats_timeout" {
  default = 120
}
variable "lambda_token_memory_size" {
  default = 128
}
variable "lambda_token_s3_key" {
  default = ""
}
variable "lambda_token_timeout" {
  default = 15
}
variable "lambda_upload_memory_size" {
  default = 128
}
variable "lambda_upload_s3_key" {
  default = ""
}
variable "lambda_upload_timeout" {
  default = 15
}
variable "lambdas_custom_s3_bucket" {
  description = "Lambdas custom S3 bucket, overrides the default local file usage, assumes we can get content from the bucket as this module does not manage this bucket"
  default     = ""
}
variable "native_regions" {
  default = ""
}
variable "optional_parameters_to_include" {
  default = []
}
variable "optional_secrets_to_include" {
  default = []
}
variable "optional_lambdas_to_include" {
  default = []
}
variable "sms_template" {
  default = ""
}
variable "sms_sender" {
  default = ""
}
variable "sms_region" {
  default = ""
}
