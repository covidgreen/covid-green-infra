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
# Admins role
# #########################################
variable "admins_role_require_mfa" {
  # Turning this on is fine with the AWS CLI but is tricky with TF and we have multiple accounts in play in some envs
  description = "Require MFA for assuming the admins IAM role"
  default     = false
}

# #########################################
# APIGateway
# If we want to limit here we can set the throttling_ values - currently -1 = no throttling
# #########################################
variable "api_gateway_account_creation_enabled" {
  description = "APIGateway account creation flag, this is used for CloudWatch logging, should only have one of these per account/region, this flag allows disabling if one already exists"
  default     = true
}
variable "api_gateway_customizations_binary_types" {
  description = "Used to condfigure the api gateway to serve additional binary types"
  type        = list(string)
  default     = []
}
variable "api_gateway_customizations_md5" {
  description = "Used to trigger deployments of API Gateway default stage on changes that are external to this repo where we have custom rources/routes/etc"
  default     = ""
}
variable "api_gateway_minimum_compression_size" {
  description = "APIGateway minimum response size to compress for the REST API. Integer between -1 and 10485760 (10MB). Setting a value greater than -1 will enable compression, -1 disables compression (default)"
  default     = -1
}
variable "api_gateway_throttling_burst_limit" {
  description = "APIGateway throttling burst limit, default is -1 which does not enforce a limit"
  default     = -1
}
variable "api_gateway_throttling_rate_limit" {
  description = "APIGateway throttling rate limit, default is -1 which does not enforce a limit"
  default     = -1
}
variable "api_gateway_timeout_milliseconds" {
  description = "APIGateway integration request timeout (in milliseconds)"
  default = 29000
}
# #########################################
# Bastion
# #########################################
variable "bastion_asg_desired_count" {
  description = "Bastion ASG desired count"
  default     = 0
}
# This allows preventing bastion access, if this is enabled the default is to have an ASG with desired count = 0
variable "bastion_enabled" {
  description = "Bastion enabled, does not provision the bastion, only allows using a bastion, see the bastion_asg_desired_count variable"
  default     = true
}
variable "bastion_instance_type" {
  description = "Bastion EC2 instance type"
  type        = string
  default     = "t2.small"
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
# Need this if we have enabled_certificates=false and have imported the certificates
variable "api_us_certificate_arn" {
  description = "ECS API certificate used by CloudFront Edge for the APIGateway (us-east-1), we use this if we do not manage the certificates and have to use an imported/existing certificate"
  default     = ""
}
variable "enable_certificates" {
  description = "Enable certificate management using AWS Certificates Manage, in some cases we do not control"
  default     = true
}
variable "enable_dns" {
  description = "Enable DNS management of Route53 records, in some cases we do not control"
  default     = true
}
# Need this if we have enabled_certificates=false and have imported the certificates
variable "push_eu_certificate_arn" {
  description = "ECS Push certificate used by the ALB, we use this if we do not manage the certificates and have to use an imported/existing certificate"
  default     = ""
}

# #########################################
# ECS Cluster Settings
# #########################################
variable "enable_ecs_container_insights" {
  description = "Enable or disable CloudWatch Container insights for the ECS cluster"
  default     = false
}

# #########################################
# ECR Settings
# #########################################
variable "default_ecr_max_image_count" {
  description = "Default ECR image retention count used for purging the ECR repositories"
  default     = 30
}

# #########################################
# Load Balancer
# #########################################
variable "lb_push_ssl_policy" {
  description = "Name of TLS policy in use"
  default     = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
}

# #########################################
# Log retention
# #########################################
variable "logs_retention_days" {
  description = "Retention in days for the logs"
  default     = 1
}

# #########################################
# Networking
# #########################################
variable "database_subnets_cidr" {
  description = "Database subnet CIDRs"
  default     = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}
variable "intra_subnets_cidr" {
  description = "Intra subnet CIDRs"
  default     = ["10.0.31.0/24", "10.0.32.0/24", "10.0.33.0/24"]
}
variable "private_subnets_cidr" {
  description = "Private subnet CIDRs"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
variable "public_subnets_cidr" {
  description = "Public subnet CIDRs"
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}
variable "vpc_cidr" {
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}

# #########################################
# R53 Settings
# #########################################
variable "api_dns" {
  description = "DNS for API service"
}
variable "push_dns" {
  description = "DNS for Push service"
}
variable "route53_zone" {
  description = "Route53 zone for DNS records"
}
variable "cognito_dns" {
  description = "DNS for cognito"
}
variable "wildcard_domain" {
  description = "DNS wildcard domain"
}

# #########################################
# RDS Settings
# #########################################
variable "rds_backup_retention" {
  description = "RDS backup retention in days"
  default     = 30
}
variable "rds_db_name" {
  description = "RDS master DB name"
}
variable "rds_cluster_family" {
  description = "RDS cluster family"
  default     = "aurora-postgresql11"
}
variable "rds_cluster_size" {
  description = "RDS cluster size, should be > 1 in non dev environments"
  default     = 1
}
variable "rds_enhanced_monitoring_interval" {
  description = "RDS enhanced monitoring metrics interval, the default is 0 which is disabled. Valid Values: 0, 1, 5, 10, 15, 30, 60. These are in seconds."
  default     = 0
}
variable "rds_instance_type" {
  description = "RDS instance type"
  default     = "db.t3.medium"
}

# #########################################
# SMS using AWS - used by the SMS lambda
# #########################################
variable "enable_sms_publishing_with_aws" {
  description = "Enable sending SMS via a SNS topic"
  default     = false
}
variable "sms_delivery_status_success_sampling_rate" {
  description = "Percentage sampling of delivery logs sent into CloudWatch"
  default     = 0
}
variable "sms_monthly_spend_limit" {
  description = "Monthly limit for SMS"
  default     = 100 # Note: this value has to be requested to the AWS Support as a quota increase ticket.
}

# #########################################
# WAF
# #########################################
variable "attach_waf" {
  description = "Attach WAF to ALBs and API Gateway - Sometimes need to detach for pen testing"
  default     = true
  type        = bool
}
# List of allowed country alpha 2 codes, see https://www.iso.org/obp/ui/#search
# If this is empty then we do not restrict based on country
variable "waf_geo_allowed_countries" {
  description = "List of countries to enable Geo blocking, if empty will be no Geo blocking"
  default     = []
}

# #########################################
# API & Lambda - Settings & Env vars
# #########################################
variable "admin_cors_origin" {
  description = "ADMIN service CORS header value"
  default     = "false"
}
variable "admin_cors_credentials" {
  description = "ADMIN service CORS credential header"
  default     = "false"
}
variable "admin_cpu_high_threshold" {
  description = "ECS ADMIN service ASG scaling CPU high threshold"
  default     = 15
}
variable "admin_cpu_low_threshold" {
  description = "ECS ADMIN service ASG scaling CPU low threshold"
  default     = 10
}
variable "admin_custom_image" {
  description = "Custom image for the ECS ADMIN container, overrides the default ECR repo, assumes we can pull from the repository"
  default     = ""
}
variable "admin_ecs_autoscale_max_instances" {
  description = "ECS ADMIN service ASG max count"
  default     = 2
}
variable "admin_ecs_autoscale_min_instances" {
  description = "ECS ADMIN service ASG min count"
  default     = 1
}
variable "admin_ecs_autoscale_scale_down_adjustment" {
  description = "ECS ADMIN service ASG scaling scale down adjustment"
  default     = -1
}
variable "admin_ecs_autoscale_scale_up_adjustment" {
  description = "ECS ADMIN service ASG scaling scale up adjustment"
  default     = 1
}
variable "admin_image_tag" {
  description = "Image tag for the ECS ADMIN container"
  default     = "latest"
}
variable "admin_listening_port" {
  description = "ECS ADMIN container port"
  default     = 5000
}
variable "admin_listening_protocol" {
  description = "API service ALB protocol"
  default     = "HTTP"
}
variable "admin_mem_high_threshold" {
  description = "ECS ADMIN service ASG scaling memory high threshold"
  default     = 25
}
variable "admin_mem_low_threshold" {
  description = "ECS ADMIN service ASG scaling memory low threshold"
  default     = 15
}
variable "admin_service_desired_count" {
  description = "ECS ADMIN service ASG desired count"
  default     = 1
}
variable "admin_services_task_cpu" {
  description = "ECS ADMIN service task CPU"
  default     = 256
}
variable "admin_services_task_memory" {
  description = "ECS ADMIN service task memory"
  default     = 512
}
variable "api_cors_origin" {
  description = "API service CORS header value"
  default     = "false"
}
variable "api_cors_credentials" {
  description = "API service CORS credentials header"
  default     = "false"
}
variable "api_cpu_high_threshold" {
  description = "ECS API service ASG scaling CPU high threshold"
  default     = 15
}
variable "api_cpu_low_threshold" {
  description = "ECS API service ASG scaling CPU low threshold"
  default     = 10
}
variable "api_custom_image" {
  description = "Custom image for the ECS API container, overrides the default ECR repo, assumes we can pull from the repository"
  default     = ""
}
variable "api_ecs_autoscale_max_instances" {
  description = "ECS API service ASG max count"
  default     = 2
}
variable "api_ecs_autoscale_min_instances" {
  description = "ECS API service ASG min count"
  default     = 1
}
variable "api_ecs_autoscale_scale_down_adjustment" {
  description = "ECS API service ASG scaling scale down adjustment"
  default     = -1
}
variable "api_ecs_autoscale_scale_up_adjustment" {
  description = "ECS API service ASG scaling scale up adjustment"
  default     = 1
}
variable "api_image_tag" {
  description = "Image tag for the ECS API container"
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
variable "api_mem_high_threshold" {
  description = "ECS API service ASG scaling memory high threshold"
  default     = 25
}
variable "api_mem_low_threshold" {
  description = "ECS API service ASG scaling memory low threshold"
  default     = 15
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
variable "app_bundle_id" {
  description = "App bundle ID used in exposure export files"
  default     = ""
}
variable "arcgis_url" {
  description = "ArcGIS URL from which stats should be loaded"
  default     = ""
}
variable "allow_no_token" {
  description = "Flag to indicate if refresh token rquired or not"
  default     = "false"
}

variable "callback_rate_limit_request_count" {
  description = "Number of callback requests allowed within the defined window"
  default     = "1"
}

variable "checkin_summary_enabled" {
  description = "If checkin data is to be summarised"
  default     = "false"
}

variable "token_lifetime_no_refresh" {
  description = "Token lifetime to use when no refresh token"
  default     = "1y"
}

variable "callback_rate_limit_secs" {
  description = "Rate limiting period for callback requests in seconds"
  default     = "60"
}
variable "certificate_audience" {
  description = "Value for the aud field in JWT generated by upload verification process"
  default     = ""
}
variable "cleanup_schedule" {
  description = "cleanup lambda CloudWatch schedule"
  default     = "cron(0 * * * ? *)"
}
variable "code_charset" {
  description = "Characters to use when generating a one-time code for uploads"
  default     = "0123456789"
}
variable "code_length" {
  description = "Length of one-time codes generated for uploads"
  default     = "6"
}
variable "code_lifetime_mins" {
  description = "Lifetime in minutes of the one-time upload codes"
}
variable "code_lifetime_deeplink_mins" {
  description = "Lifetime in minutes of the one-time deeplink upload codes"
  default     = "1440"
}
variable "code_deeplinks_allowed" {
  description = "Are deeplink codes allowed"
  default     = "false"
}

variable "code_removal_mins" {
  description = "Lifetime in minutes before a one-time upload code is removed from the database"
  default     = "2880"
}
variable "cso_schedule" {
  description = "cso lambda CloudWatch schedule"
  default     = "cron(0 0 * * ? *)"
}
variable "daily_registrations_reporter_email_subject" {
  description = "daily-registrations-reporter lambda email subject text"
  default     = ""
}
variable "daily_registrations_reporter_schedule" {
  description = "daily-registrations-reporter lambda CloudWatch schedule"
  default     = ""
}
variable "db_pool_size" {
  description = "Maximum number of clients the db pool should contain"
  default     = "30"
}

variable "deeplink_android_package_name" {
  description = "Android package name used in deeplink redirects"
  default     = "na"
}

variable "deeplink_appstore_link" {
  description = "Appstore link used in deeplink redirects"
  default     = "na"
}

variable "deeplink_default_webpage" {
  description = "Default landing page used in deeplink redirects"
  default     = "na"
}

variable "default_country_code" {
  description = "Default ISO country code to use for parsing mobile numbers provided to push service"
  default     = ""
}
variable "default_region" {
  description = "Default region to use for exposure key uploads where the region is not provided"
  default     = ""
}
variable "disable_valid_key_check" {
  description = "Flag to disable whether exposure keys which are still valid are ignored when generating export files"
  default     = "false"
}
variable "download_schedule" {
  description = "download lambda CloudWatch schedule"
  default     = "cron(30 * * * ? *)"
}
variable "enable_callback" {
  description = "Flag to determine whether the API service should enable callback endpoints"
  default     = "true"
}
variable "enable_callback_email_notifications" {
  description = "Flag to determine if requests sent to the callback SQS queue can be forwarded to an SNS email subscription"
  default     = "false"
}
variable "enable_check_in" {
  description = "Flag to determine whether the API service should enable check-in endpoints"
  default     = "true"
}
variable "enable_legacy_settings" {
  description = "Flag to determine whether the legacy /settings endpoint is enabled which returns all settings in a single file"
  default     = "false"
}
variable "enable_metrics" {
  description = "Flag to determine whether the API service should enable metrics endpoints"
  default     = "true"
}
variable "exposure_schedule" {
  description = "exposures lambda CloudWatch schedule"
}
variable "health_check_healthy_threshold" {
  description = "Health check healthy threshold for ALB health checks"
  default     = 3
}
variable "health_check_interval" {
  description = "Health check interval for ALB health checks"
  default     = 10
}
variable "health_check_matcher" {
  description = "Health check matcher for ALB health checks"
  default     = "200"
}
variable "health_check_path" {
  description = "Health check path"
  default     = "/healthcheck"
}
variable "health_check_timeout" {
  description = "Health check timeout for ALB health checks"
  default     = 5
}
variable "health_check_unhealthy_threshold" {
  description = "Health check unhealthy threshold for ALB health checks"
  default     = 2
}
variable "hsts_max_age" {
  description = "The time, in seconds, that the browser should remember that a site is only to be accessed using HTTPS."
  default     = "300" // 5 minutes
}
variable "interop_origin" {
  description = "The origin country for keys."
  default     = ""
}
variable "issue_proxy_url" {
  description = "URL to proxy OTC issue requests if necessary"
  default     = ""
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
  default     = 300
}
variable "lambda_custom_runtimes" {
  description = "Map of lambdas to use custom runtimes, where the value is an object with the runtime and layers to use i.e. { \"authorizer\" : { \"runtime\": \"provided\", \"layers\": [\"some-arn\"] } }"
  default     = {}
}
variable "lambda_cso_memory_size" {
  description = "cso lambda memory size"
  default     = 3008
}
variable "lambda_cleanup_memory_size" {
  description = "cleanup lambda memory size"
  default     = 128
}
variable "lambda_cleanup_s3_key" {
  description = "cleanup lambda S3 key if using - file path"
  default     = ""
}
variable "lambda_cleanup_timeout" {
  description = "cleanup lambda timeout"
  default     = 300
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
  default     = 300
}
variable "lambda_default_runtime" {
  description = "Default lambda runtime"
  default     = "nodejs12.x"
}
variable "lambda_download_memory_size" {
  description = "download lambda memory size"
  default     = 256
}
variable "lambda_download_s3_key" {
  description = "download lambda S3 key if using - file path"
  default     = ""
}
variable "lambda_download_timeout" {
  description = "download lambda timeout"
  default     = 300
}
variable "lambda_exposures_memory_size" {
  description = "exposures lambda memory size"
  default     = 256
}
variable "lambda_exposures_s3_key" {
  description = "exposures lambda S3 key if using - file path"
  default     = ""
}
variable "lambda_exposures_timeout" {
  description = "exposures lambda timeout"
  default     = 300
}
variable "lambda_provisioned_concurrencies" {
  description = "Map of lambdas to use provisioned concurrency i.e. { \"authorizer\" : 300 }"
  default     = {}
}
variable "lambda_settings_memory_size" {
  description = "settings lambda memory size"
  default     = 256
}
variable "lambda_settings_s3_key" {
  description = "settings lambda S3 key if using - file path"
  default     = ""
}
variable "lambda_settings_timeout" {
  description = "settings lambda timeout"
  default     = 300
}
variable "lambda_sms_memory_size" {
  description = "sms lambda memory size"
  default     = 256
}
variable "lambda_sms_s3_key" {
  description = "sms lambda S3 key if using - file path"
  default     = ""
}
variable "lambda_sms_timeout" {
  description = "sms lambda timeout"
  default     = 300
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
  default     = 300
}
variable "lambda_token_memory_size" {
  description = "token lambda memory size"
  default     = 256
}
variable "lambda_token_s3_key" {
  description = "token lambda S3 key if using - file path"
  default     = ""
}
variable "lambda_token_timeout" {
  description = "token lambda timeout"
  default     = 300
}
variable "lambda_upload_memory_size" {
  description = "upload lambda memory size"
  default     = 256
}
variable "lambda_upload_s3_key" {
  description = "upload lambda S3 key if using - file path"
  default     = ""
}
variable "lambda_upload_timeout" {
  description = "upload lambda timeout"
  default     = 300
}
variable "lambdas_custom_s3_bucket" {
  description = "Lambdas custom S3 bucket, overrides the default local file usage, assumes we can get content from the bucket as this module does not manage this bucket"
  default     = ""
}
variable "log_level" {
  description = "Log level for ECS and lambdas"
}
variable "log_callback_request" {
  description = "Log callback request payload"
  default     = "false"
}
variable "native_regions" {
  description = "Comma separated list of regions to include with the default region when generating exposure export files"
  default     = ""
}
variable "metrics_config" {
  default = "{ \"UPLOAD_AFTER_CONTACT\": 60, \"CHECK_IN\": 60, \"FORGET\": 60, \"CALLBACK_OPTIN\": 60, \"DAILY_ACTIVE_TRACE\": 60, \"CONTACT_NOTIFICATION\": 60, \"LOG_ERROR\": 60 }"
}
variable "migrations_custom_image" {
  description = "Custom image for the ECS Migrations container, overrides the default ECR repo, assumes we can pull from the repository"
  default     = ""
}
variable "migrations_image_tag" {
  description = "Image tag for the ECS Migrations container"
  default     = "latest"
}
variable "onset_date_mandatory" {
  description = "Flag whether onsetDate/symptomDate is mandatory"
  default     = "false"
}
variable "enforce_onset_date_range_error" {
  description = "Flag whether onsetDate/symptomDate outside of allowed range generates an error"
  default     = "false"
}
variable "optional_lambdas_to_include" {
  description = "List of optional lambdas to include"
  default     = []
}
variable "optional_parameters_to_include" {
  description = "List of optional parameters to include"
  default     = []
}
variable "optional_secrets_to_include" {
  description = "List of optional secrets to include"
  default     = []
}
variable "push_allowed_ips" {
  description = "ECS Push service ALB allowed ingress CIDRs"
  default     = ["0.0.0.0/0"]
}
variable "push_cors_origin" {
  description = "Push service CORS header value"
  default     = "false"
}
variable "push_cors_credentials" {
  description = "Push service CORS credentials header"
  default     = "false"
}
variable "push_cpu_high_threshold" {
  description = "ECS Push service ASG scaling CPU high threshold"
  default     = 15
}
variable "push_cpu_low_threshold" {
  description = "ECS Push service ASG scaling CPU low threshold"
  default     = 10
}
variable "push_custom_image" {
  description = "Custom image for the ECS Push container, overrides the default ECR repo, assumes we can pull from the repository"
  default     = ""
}
variable "push_ecs_autoscale_max_instances" {
  description = "ECS Push service ASG max count"
  default     = 1
}
variable "push_ecs_autoscale_min_instances" {
  description = "ECS Push service ASG min count"
  default     = 1
}
variable "push_ecs_autoscale_scale_down_adjustment" {
  description = "ECS Push service ASG scaling scale down adjustment"
  default     = -1
}
variable "push_ecs_autoscale_scale_up_adjustment" {
  description = "ECS Push service ASG scaling scale up adjustment"
  default     = 1
}
variable "push_image_tag" {
  description = "Image tag for the ECS Push container"
  default     = "latest"
}
variable "push_listening_port" {
  description = "ECS Push container port"
  default     = 6000
}
variable "push_listening_protocol" {
  description = "Push service ALB protocol"
  default     = "HTTP"
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
variable "push_services_task_cpu" {
  description = "ECS Push service task CPU"
  default     = 256
}
variable "push_services_task_memory" {
  description = "ECS Push service task memory"
  default     = 512
}
variable "reduced_metrics_whitelist" {
  description = "Comma separated list of metrics the reduced metrics role can access"
  default     = "CALLBACK_OPTIN,CALLBACK_SENT,CASES,CHECK_IN,DEATHS,FORGET,INTEROP_KEYS_DOWNLOADED,INTEROP_KEYS_UPLOADED,UPLOAD,SMS_SENT,CONTACT_NOTIFICATION"
}
variable "refresh_token_expiry" {
  description = "Lifetime of refresh tokens generated after a user registers"
  default     = "10y"
}
variable "settings_schedule" {
  description = "settings lambda CloudWatch schedule"
}
variable "sms_region" {
  description = "AWS region to use when sending SMS messages"
  default     = ""
}
variable "sms_scheduling_schedule" {
  description = "SMS scheduling lambda cloudwatch schedule"
  default     = "cron(*/5 * * * ? *)"
}
variable "sms_scheduling" {
  description = "SMS scheduling time windows, used to define schedukes for repeating OTC sends"
  default     = ""
}
variable "sms_quiet_time" {
  description = "SMS time windows during which not to send scheduled SMS OTCs"
  default     = ""
}
variable "sms_sender" {
  description = "SMS message sender identifier"
  default     = ""
}
variable "sms_template" {
  description = "SMS message template"
  default     = ""
}
variable "sms_type" {
  description = "SMS message type"
  default     = "Transactional"
}
variable "symptom_date_offset" {
  description = "Offset in hours subtracted from the symptom or onset date for uploads"
  default     = "0"
}
variable "time_zone" {
  description = "Time zone used for localisation of endpoints that are rate limited to once per day, for example /check-in"
  default     = "UTC"
}
variable "token_lifetime_mins" {
  description = "Token lifetime in minutes"
}
variable "upload_max_keys" {
  description = "Maximum keys accepted in a single upload request"
  default     = "20"
}
variable "upload_schedule" {
  description = "upload lambda CloudWatch schedule"
  default     = "cron(0 * * * ? *)"
}
variable "upload_token_lifetime_mins" {
  description = "Lifetime of tokens which are generated in exchange for a valid one-time upload code"
  default     = "1440"
}
variable "use_test_date_as_onset_date" {
  description = "Flag to use the testDate as the onsetDate if the latter is omitted"
  default     = "false"
}
variable "variance_offset_mins" {
  description = "Variance offset in minutes to add to lifetime of keys to check if they are still valid"
  default     = "120"
}
variable "verify_proxy_url" {
  description = "URL to code verification requests if necessary"
  default     = ""
}
variable "verify_rate_limit_secs" {
  description = "Time in seconds a user must wait before attempting to verify a one-time upload code"
}

variable "self_isolation_notice_lifetime_mins" {
  description = "Self isolation notice lifetime in minutes"
  default     = 20160
}

variable "lambda_self_isolation_timeout" {
  description = "Self isolation lambda timeout in seconds"
  default     = 600
}
variable "lambda_self_isolation_memory_size" {
  description = "Self isolation lambda memory size"
  default     = 512
}

variable "security_self_isolation_notices_rate_limit_secs" {
  type        = number
  description = "Self isolation notices rate limit in seconds"
  default     = 86400
}

variable "self_isolation_notices_enabled" {
  type        = string
  description = "Enable/disable self isolation notices"
  default     = "false"
}

variable "enx_logo_supported" {
  type        = string
  description = "Enable/disable reporting on enx logo metrics"
  default     = "false"
}

variable "allowed_test_types" {
  type        = string
  description = "The test types to accept"
  default     = "[1]"
}