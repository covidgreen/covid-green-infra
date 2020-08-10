# #########################################
# Misc
# #########################################
variable "namespace" {}
variable "full_name" {}
variable "environment" {}
variable "profile" {}
variable "root_profile" {}
variable "aws_region" {}


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
variable "exposure_limit" {
  default = "10"
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
  default = "{ \"CONTACT_UPLOAD\": 60, \"CHECK_IN\": 60, \"FORGET\": 60, \"TOKEN_RENEWAL\": 60, \"CALLBACK_OPTIN\": 60, \"CALLBACK_REQUEST\": 60, \"DAILY_ACTIVE_TRACE\": 60, \"CONTACT_NOTIFICATION\": 60 }"
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
variable "enable_check_in" {
  default = "true"
}
variable "enable_metrics" {
  default = "true"
}
variable "default_country_code" {
  default = ""
}
variable "default_region" {
  default = ""
}
variable "lambda_provisioned_concurrencies" {
  default = {}
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
variable "authorizer_lambda_s3_bucket" {
  description = "S3 bucket name where the lambda content will be found"
  type        = string
  default     = ""
}

variable "authorizer_lambda_s3_key" {
  description = "S3 key where the lambda archive will be found. This should be a path relative to the bucket root."
  type        = string
  default     = ""
}

variable "callback_lambda_s3_bucket" {
  description = "S3 bucket name where the lambda content will be found"
  type        = string
  default     = ""
}

variable "callback_lambda_s3_key" {
  description = "S3 key where the lambda archive will be found. This should be a path relative to the bucket root."
  type        = string
  default     = ""
}

variable "cso_lambda_s3_bucket" {
  description = "S3 bucket name where the lambda content will be found"
  type        = string
  default     = ""
}

variable "cso_lambda_s3_key" {
  description = "S3 key where the lambda archive will be found. This should be a path relative to the bucket root."
  type        = string
  default     = ""
}

variable "token_lambda_s3_bucket" {
  description = "S3 bucket name where the lambda content will be found"
  type        = string
  default     = ""
}

variable "token_lambda_s3_key" {
  description = "S3 key where the lambda archive will be found. This should be a path relative to the bucket root."
  type        = string
  default     = ""
}

variable "settings_lambda_s3_bucket" {
  description = "S3 bucket name where the lambda content will be found"
  type        = string
  default     = ""
}

variable "settings_lambda_s3_key" {
  description = "S3 key where the lambda archive will be found. This should be a path relative to the bucket root."
  type        = string
  default     = ""
}

variable "exposures_lambda_s3_key" {
  description = "S3 key where the lambda archive will be found. This should be a path relative to the bucket root."
  type        = string
  default     = ""
}

variable "exposures_lambda_s3_bucket" {
  description = "S3 bucket name where the lambda content will be found"
  type        = string
  default     = ""
}

variable "stats_lambda_s3_key" {
  description = "S3 key where the lambda archive will be found. This should be a path relative to the bucket root."
  type        = string
  default     = ""
}

variable "stats_lambda_s3_bucket" {
  description = "S3 bucket name where the lambda content will be found"
  type        = string
  default     = ""
}

variable "api_container_repo_url" {
  description = "ECR repo to be deployed into ECS for the API container"
  type        = string
  default     = ""
}

variable "migrations_container_repo_url" {
  description = "ECR repo to be deployed into ECS for the Migration container"
  type        = string
  default     = ""
}

variable "api_container_tag" {
  description = "ECR tag to be deployed into ECS for the API & Migration containers"
  type        = string
  default     = "latest"
}

variable "push_container_repo_url" {
  description = "ECR repo to be deployed into ECS for the Push API container"
  type        = string
  default     = ""
}

variable "push_container_tag" {
  description = "ECR tag to be deployed into ECS for the Push API container"
  type        = string
  default     = "latest"
}
