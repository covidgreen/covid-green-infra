# #########################################
# Parameters
# #########################################
resource "aws_ssm_parameter" "api_host" {
  overwrite = true
  name      = "${local.config_var_prefix}api_host"
  type      = "String"
  value     = "0.0.0.0"
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "api_port" {
  overwrite = true
  name      = "${local.config_var_prefix}api_port"
  type      = "String"
  value     = var.api_listening_port
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "app_bundle_id" {
  overwrite = true
  name      = "${local.config_var_prefix}app_bundle_id"
  type      = "String"
  value     = var.app_bundle_id
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "callback_url" {
  overwrite = true
  name      = "${local.config_var_prefix}callback_url"
  type      = "String"
  value     = aws_sqs_queue.callback.id
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "cors_origin" {
  overwrite = true
  name      = "${local.config_var_prefix}cors_origin"
  type      = "String"
  value     = var.api_cors_origin
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "db_database" {
  overwrite = true
  name      = "${local.config_var_prefix}db_database"
  type      = "String"
  value     = var.rds_db_name
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "db_host" {
  overwrite = true
  name      = "${local.config_var_prefix}db_host"
  type      = "String"
  value     = module.rds_cluster_aurora_postgres.endpoint
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "db_pool_size" {
  overwrite = true
  name      = "${local.config_var_prefix}db_pool_size"
  type      = "String"
  value     = var.db_pool_size
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "db_port" {
  overwrite = true
  name      = "${local.config_var_prefix}db_port"
  type      = "String"
  value     = 5432
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "db_reader_host" {
  overwrite = true
  name      = "${local.config_var_prefix}db_reader_host"
  type      = "String"
  value     = module.rds_cluster_aurora_postgres.reader_endpoint
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "db_ssl" {
  overwrite = true
  name      = "${local.config_var_prefix}db_ssl"
  type      = "String"
  value     = "true"
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "default_country_code" {
  overwrite = true
  name      = "${local.config_var_prefix}default_country_code"
  type      = "String"
  value     = var.default_country_code
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "default_region" {
  overwrite = true
  name      = "${local.config_var_prefix}default_region"
  type      = "String"
  value     = var.default_region
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "disable_valid_key_check" {
  overwrite = true
  name      = "${local.config_var_prefix}disable_valid_key_check"
  type      = "String"
  value     = var.disable_valid_key_check
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "enable_callback" {
  overwrite = true
  name      = "${local.config_var_prefix}enable_callback"
  type      = "String"
  value     = var.enable_callback
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "enable_check_in" {
  overwrite = true
  name      = "${local.config_var_prefix}enable_check_in"
  type      = "String"
  value     = var.enable_check_in
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "enable_legacy_settings" {
  overwrite = true
  name      = "${local.config_var_prefix}enable_legacy_settings"
  type      = "String"
  value     = var.enable_legacy_settings
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "enable_metrics" {
  overwrite = true
  name      = "${local.config_var_prefix}enable_metrics"
  type      = "String"
  value     = var.enable_metrics
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "certificate_audience" {
  overwrite = true
  name      = "${local.config_var_prefix}certificate_audience"
  type      = "String"
  value     = var.certificate_audience
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "hsts_max_age" {
  overwrite = true
  name      = "${local.config_var_prefix}hsts_max_age"
  type      = "String"
  value     = var.hsts_max_age
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "jwt_issuer" {
  overwrite = true
  name      = "${local.config_var_prefix}jwt_issuer"
  type      = "String"
  value     = var.app_bundle_id
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "log_level" {
  overwrite = true
  name      = "${local.config_var_prefix}log_level"
  type      = "String"
  value     = var.log_level
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "metrics_config" {
  overwrite = true
  name      = "${local.config_var_prefix}metrics_config"
  type      = "String"
  value     = var.metrics_config
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "native_regions" {
  overwrite = true
  name      = "${local.config_var_prefix}native_regions"
  type      = "String"
  value     = var.native_regions
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "onset_date_mandatory" {
  overwrite = true
  name      = "${local.config_var_prefix}onset_date_mandatory"
  type      = "String"
  value     = var.onset_date_mandatory
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "push_host" {
  overwrite = true
  name      = "${local.config_var_prefix}push_host"
  type      = "String"
  value     = "0.0.0.0"
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "push_port" {
  overwrite = true
  name      = "${local.config_var_prefix}push_port"
  type      = "String"
  value     = var.push_listening_port
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "s3_assets_bucket" {
  overwrite = true
  name      = "${local.config_var_prefix}s3_assets_bucket"
  type      = "String"
  value     = aws_s3_bucket.assets.id
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "security_code_charset" {
  overwrite = true
  name      = "${local.config_var_prefix}security_code_charset"
  type      = "String"
  value     = var.code_charset
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "security_code_length" {
  overwrite = true
  name      = "${local.config_var_prefix}security_code_length"
  type      = "String"
  value     = var.code_length
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "security_code_lifetime_mins" {
  overwrite = true
  name      = "${local.config_var_prefix}security_code_lifetime_mins"
  type      = "String"
  value     = var.code_lifetime_mins
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "security_code_removal_mins" {
  overwrite = true
  name      = "${local.config_var_prefix}security_code_removal_mins"
  type      = "String"
  value     = var.code_removal_mins
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "security_refresh_token_expiry" {
  overwrite = true
  name      = "${local.config_var_prefix}security_refresh_token_expiry"
  type      = "String"
  value     = var.refresh_token_expiry
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "security_token_lifetime_mins" {
  overwrite = true
  name      = "${local.config_var_prefix}security_token_lifetime_mins"
  type      = "String"
  value     = var.token_lifetime_mins
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "security_verify_rate_limit_secs" {
  overwrite = true
  name      = "${local.config_var_prefix}security_verify_rate_limit_secs"
  type      = "String"
  value     = var.verify_rate_limit_secs
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "sms_region" {
  overwrite = true
  name      = "${local.config_var_prefix}sms_region"
  type      = "String"
  value     = var.sms_region
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "sms_sender" {
  overwrite = true
  name      = "${local.config_var_prefix}sms_sender"
  type      = "String"
  value     = var.sms_sender
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "sms_template" {
  overwrite = true
  name      = "${local.config_var_prefix}sms_template"
  type      = "String"
  value     = var.sms_template
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "sms_url" {
  overwrite = true
  name      = "${local.config_var_prefix}sms_url"
  type      = "String"
  value     = aws_sqs_queue.sms.id
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "symptom_date_offset" {
  overwrite = true
  name      = "${local.config_var_prefix}symptom_date_offset"
  type      = "String"
  value     = var.symptom_date_offset
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "time_zone" {
  overwrite = true
  name      = "${local.config_var_prefix}time_zone"
  type      = "String"
  value     = var.time_zone
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "upload_max_keys" {
  overwrite = true
  name      = "${local.config_var_prefix}upload_max_keys"
  type      = "String"
  value     = var.upload_max_keys
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "upload_token_lifetime_mins" {
  overwrite = true
  name      = "${local.config_var_prefix}upload_token_lifetime_mins"
  type      = "String"
  value     = var.upload_token_lifetime_mins
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "use_test_date_as_onset_date" {
  overwrite = true
  name      = "${local.config_var_prefix}use_test_date_as_onset_date"
  type      = "String"
  value     = var.use_test_date_as_onset_date
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "variance_offset_mins" {
  overwrite = true
  name      = "${local.config_var_prefix}variance_offset_mins"
  type      = "String"
  value     = var.variance_offset_mins
  tags      = module.labels.tags
}

# #########################################
# Optional parameters - These exist for some instances
# #########################################
resource "aws_ssm_parameter" "arcgis_url" {
  count     = contains(var.optional_parameters_to_include, "arcgis_url") ? 1 : 0
  overwrite = true
  name      = "${local.config_var_prefix}arcgis_url"
  type      = "String"
  value     = var.arcgis_url
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "callback_email_notifications_sns_arn" {
  count     = local.enable_callback_email_notifications_count
  overwrite = true
  name      = "${local.config_var_prefix}callback_email_notifications_sns_arn"
  type      = "String"
  value     = join("", aws_sns_topic.callback_email_notifications.*.arn)
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "daily_registrations_reporter_email_subject" {
  count     = contains(var.optional_parameters_to_include, "daily_registrations_reporter_email_subject") ? 1 : 0
  overwrite = true
  name      = "${local.config_var_prefix}daily_registrations_reporter_email_subject"
  type      = "String"
  value     = var.daily_registrations_reporter_email_subject
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "daily_registrations_reporter_sns_arn" {
  count     = contains(var.optional_parameters_to_include, "daily_registrations_reporter_sns_arn") ? 1 : 0
  overwrite = true
  name      = "${local.config_var_prefix}daily_registrations_reporter_sns_arn"
  type      = "String"
  value     = join("", aws_sns_topic.daily_registrations_reporter.*.arn)
  tags      = module.labels.tags
}
