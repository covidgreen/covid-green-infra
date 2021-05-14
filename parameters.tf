# #########################################
# Parameters
# #########################################
resource "aws_ssm_parameter" "admin_cognito_user_pool_id" {
  overwrite = true
  name      = format("%sadmin_cognito_user_pool_id", local.config_var_prefix)
  type      = "String"
  value     = aws_cognito_user_pool.admin_user_pool.id
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "admin_cognito_region" {
  overwrite = true
  name      = format("%sadmin_cognito_region", local.config_var_prefix)
  type      = "String"
  value     = var.aws_region
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "admin_cors_origin" {
  overwrite = true
  name      = format("%sadmin_cors_origin", local.config_var_prefix)
  type      = "String"
  value     = var.admin_cors_origin
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "admin_cors_credentials" {
  overwrite = true
  name      = format("%sadmin_cors_credentials", local.config_var_prefix)
  type      = "String"
  value     = var.admin_cors_credentials
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "admin_host" {
  overwrite = true
  name      = format("%sadmin_host", local.config_var_prefix)
  type      = "String"
  value     = "0.0.0.0"
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "admin_port" {
  overwrite = true
  name      = format("%sadmin_port", local.config_var_prefix)
  type      = "String"
  value     = var.admin_listening_port
  tags      = module.labels.tags
}


resource "aws_ssm_parameter" "api_host" {
  overwrite = true
  name      = format("%sapi_host", local.config_var_prefix)
  type      = "String"
  value     = "0.0.0.0"
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "api_port" {
  overwrite = true
  name      = format("%sapi_port", local.config_var_prefix)
  type      = "String"
  value     = var.api_listening_port
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "app_bundle_id" {
  overwrite = true
  name      = format("%sapp_bundle_id", local.config_var_prefix)
  type      = "String"
  value     = var.app_bundle_id
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "callback_url" {
  overwrite = true
  name      = format("%scallback_url", local.config_var_prefix)
  type      = "String"
  value     = aws_sqs_queue.callback.id
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "checkin_summary_enabled" {
  overwrite = true
  name      = format("%scheckin_summary_enabled", local.config_var_prefix)
  type      = "String"
  value     = var.checkin_summary_enabled
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "cors_origin" {
  overwrite = true
  name      = format("%scors_origin", local.config_var_prefix)
  type      = "String"
  value     = var.api_cors_origin
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "cors_credentials" {
  overwrite = true
  name      = format("%scors_credentials", local.config_var_prefix)
  type      = "String"
  value     = var.api_cors_credentials
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "deeplink_android_package_name" {
  overwrite = true
  name      = format("%sdeeplink_android_package_name", local.config_var_prefix)
  type      = "String"
  value     = var.deeplink_android_package_name
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "deeplink_appstore_link" {
  overwrite = true
  name      = format("%sdeeplink_appstore_link", local.config_var_prefix)
  type      = "String"
  value     = var.deeplink_appstore_link
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "deeplink_default_webpage" {
  overwrite = true
  name      = format("%sdeeplink_default_webpage", local.config_var_prefix)
  type      = "String"
  value     = var.deeplink_default_webpage
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "db_database" {
  overwrite = true
  name      = format("%sdb_database", local.config_var_prefix)
  type      = "String"
  value     = var.rds_db_name
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "db_host" {
  overwrite = true
  name      = format("%sdb_host", local.config_var_prefix)
  type      = "String"
  value     = module.rds_cluster_aurora_postgres.endpoint
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "db_pool_size" {
  overwrite = true
  name      = format("%sdb_pool_size", local.config_var_prefix)
  type      = "String"
  value     = var.db_pool_size
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "db_port" {
  overwrite = true
  name      = format("%sdb_port", local.config_var_prefix)
  type      = "String"
  value     = 5432
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "db_reader_host" {
  overwrite = true
  name      = format("%sdb_reader_host", local.config_var_prefix)
  type      = "String"
  value     = module.rds_cluster_aurora_postgres.reader_endpoint
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "db_ssl" {
  overwrite = true
  name      = format("%sdb_ssl", local.config_var_prefix)
  type      = "String"
  value     = "true"
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "default_country_code" {
  overwrite = true
  name      = format("%sdefault_country_code", local.config_var_prefix)
  type      = "String"
  value     = var.default_country_code
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "default_region" {
  overwrite = true
  name      = format("%sdefault_region", local.config_var_prefix)
  type      = "String"
  value     = var.default_region
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "disable_valid_key_check" {
  overwrite = true
  name      = format("%sdisable_valid_key_check", local.config_var_prefix)
  type      = "String"
  value     = var.disable_valid_key_check
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "enable_callback" {
  overwrite = true
  name      = format("%senable_callback", local.config_var_prefix)
  type      = "String"
  value     = var.enable_callback
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "enable_check_in" {
  overwrite = true
  name      = format("%senable_check_in", local.config_var_prefix)
  type      = "String"
  value     = var.enable_check_in
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "enable_legacy_settings" {
  overwrite = true
  name      = format("%senable_legacy_settings", local.config_var_prefix)
  type      = "String"
  value     = var.enable_legacy_settings
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "enable_metrics" {
  overwrite = true
  name      = format("%senable_metrics", local.config_var_prefix)
  type      = "String"
  value     = var.enable_metrics
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "certificate_audience" {
  overwrite = true
  name      = format("%scertificate_audience", local.config_var_prefix)
  type      = "String"
  value     = var.certificate_audience
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "hsts_max_age" {
  overwrite = true
  name      = format("%shsts_max_age", local.config_var_prefix)
  type      = "String"
  value     = var.hsts_max_age
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "interop_origin" {
  count     = contains(var.optional_parameters_to_include, "interop_origin") ? 1 : 0
  overwrite = true
  name      = format("%sinterop_origin", local.config_var_prefix)
  type      = "String"
  value     = var.interop_origin
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "jwt_issuer" {
  overwrite = true
  name      = format("%sjwt_issuer", local.config_var_prefix)
  type      = "String"
  value     = var.app_bundle_id
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "log_level" {
  overwrite = true
  name      = format("%slog_level", local.config_var_prefix)
  type      = "String"
  value     = var.log_level
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "log_callback_request" {
  overwrite = true
  name      = format("%slog_callback_request", local.config_var_prefix)
  type      = "String"
  value     = var.log_callback_request
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "metrics_config" {
  overwrite = true
  name      = format("%smetrics_config", local.config_var_prefix)
  type      = "String"
  value     = var.metrics_config
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "native_regions" {
  overwrite = true
  name      = format("%snative_regions", local.config_var_prefix)
  type      = "String"
  value     = var.native_regions
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "onset_date_mandatory" {
  overwrite = true
  name      = format("%sonset_date_mandatory", local.config_var_prefix)
  type      = "String"
  value     = var.onset_date_mandatory
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "enforce_onset_date_range_error" {
  overwrite = true
  name      = format("%senforce_onset_date_range_error", local.config_var_prefix)
  type      = "String"
  value     = var.enforce_onset_date_range_error
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "push_service_url" {
  overwrite = true
  name      = format("%spush_service_url", local.config_var_prefix)
  type      = "String"
  value     = format("https://%s", aws_lb.push.dns_name)
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "push_cors_origin" {
  overwrite = true
  name      = format("%spush_cors_origin", local.config_var_prefix)
  type      = "String"
  value     = var.push_cors_origin
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "push_cors_credentials" {
  overwrite = true
  name      = format("%spush_cors_credentials", local.config_var_prefix)
  type      = "String"
  value     = var.push_cors_credentials
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "push_host" {
  overwrite = true
  name      = format("%spush_host", local.config_var_prefix)
  type      = "String"
  value     = "0.0.0.0"
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "push_port" {
  overwrite = true
  name      = format("%spush_port", local.config_var_prefix)
  type      = "String"
  value     = var.push_listening_port
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "reduced_metrics_whitelist" {
  overwrite = true
  name      = format("%sreduced_metrics_whitelist", local.config_var_prefix)
  type      = "String"
  value     = var.reduced_metrics_whitelist
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "s3_assets_bucket" {
  overwrite = true
  name      = format("%ss3_assets_bucket", local.config_var_prefix)
  type      = "String"
  value     = aws_s3_bucket.assets.id
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "security_code_charset" {
  overwrite = true
  name      = format("%ssecurity_code_charset", local.config_var_prefix)
  type      = "String"
  value     = var.code_charset
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "security_code_length" {
  overwrite = true
  name      = format("%ssecurity_code_length", local.config_var_prefix)
  type      = "String"
  value     = var.code_length
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "security_code_lifetime_mins" {
  overwrite = true
  name      = format("%ssecurity_code_lifetime_mins", local.config_var_prefix)
  type      = "String"
  value     = var.code_lifetime_mins
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "security_code_lifetime_deeplink_mins" {
  overwrite = true
  name      = format("%ssecurity_code_lifetime_deeplink_mins", local.config_var_prefix)
  type      = "String"
  value     = var.code_lifetime_deeplink_mins
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "security_code_deeplinks_allowed" {
  overwrite = true
  name      = format("%ssecurity_code_deeplinks_allowed", local.config_var_prefix)
  type      = "String"
  value     = var.code_deeplinks_allowed
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "security_code_removal_mins" {
  overwrite = true
  name      = format("%ssecurity_code_removal_mins", local.config_var_prefix)
  type      = "String"
  value     = var.code_removal_mins
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "security_refresh_token_expiry" {
  overwrite = true
  name      = format("%ssecurity_refresh_token_expiry", local.config_var_prefix)
  type      = "String"
  value     = var.refresh_token_expiry
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "security_token_lifetime_mins" {
  overwrite = true
  name      = format("%ssecurity_token_lifetime_mins", local.config_var_prefix)
  type      = "String"
  value     = var.token_lifetime_mins
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "security_token_lifetime_no_refresh" {
  overwrite = true
  name      = format("%ssecurity_token_lifetime_no_refresh", local.config_var_prefix)
  type      = "String"
  value     = var.token_lifetime_no_refresh
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "security_verify_rate_limit_secs" {
  overwrite = true
  name      = format("%ssecurity_verify_rate_limit_secs", local.config_var_prefix)
  type      = "String"
  value     = var.verify_rate_limit_secs
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "sms_region" {
  overwrite = true
  name      = format("%ssms_region", local.config_var_prefix)
  type      = "String"
  value     = var.sms_region
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "sms_scheduling" {
  count     = contains(var.optional_parameters_to_include, "sms_scheduling") ? 1 : 0
  overwrite = true
  name      = format("%ssms_scheduling", local.config_var_prefix)
  type      = "String"
  value     = var.sms_scheduling
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "sms_quiet_time" {
  count     = contains(var.optional_parameters_to_include, "sms_quiet_time") ? 1 : 0
  overwrite = true
  name      = format("%ssms_quiet_time", local.config_var_prefix)
  type      = "String"
  value     = var.sms_quiet_time
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "sms_sender" {
  overwrite = true
  name      = format("%ssms_sender", local.config_var_prefix)
  type      = "String"
  value     = var.sms_sender
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "sms_template" {
  overwrite = true
  name      = format("%ssms_template", local.config_var_prefix)
  type      = "String"
  value     = var.sms_template
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "sms_url" {
  overwrite = true
  name      = format("%ssms_url", local.config_var_prefix)
  type      = "String"
  value     = aws_sqs_queue.sms.id
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "symptom_date_offset" {
  overwrite = true
  name      = format("%ssymptom_date_offset", local.config_var_prefix)
  type      = "String"
  value     = var.symptom_date_offset
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "time_zone" {
  overwrite = true
  name      = format("%stime_zone", local.config_var_prefix)
  type      = "String"
  value     = var.time_zone
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "upload_max_keys" {
  overwrite = true
  name      = format("%supload_max_keys", local.config_var_prefix)
  type      = "String"
  value     = var.upload_max_keys
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "upload_token_lifetime_mins" {
  overwrite = true
  name      = format("%supload_token_lifetime_mins", local.config_var_prefix)
  type      = "String"
  value     = var.upload_token_lifetime_mins
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "use_test_date_as_onset_date" {
  overwrite = true
  name      = format("%suse_test_date_as_onset_date", local.config_var_prefix)
  type      = "String"
  value     = var.use_test_date_as_onset_date
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "variance_offset_mins" {
  overwrite = true
  name      = format("%svariance_offset_mins", local.config_var_prefix)
  type      = "String"
  value     = var.variance_offset_mins
  tags      = module.labels.tags
}


# Self isolation specific parameters
resource "aws_ssm_parameter" "self_isolation_notice_lifetime_mins" {
  name  = format("%s-self_isolation_notice_lifetime_mins", module.labels.id)
  type  = "String"
  value = var.self_isolation_notice_lifetime_mins
}

resource "aws_ssm_parameter" "notices_sqs_arn" {
  name  = format("%s-%s", module.labels.id, "self_isolation_notices_sqs_arn")
  type  = "String"
  value = aws_sqs_queue.self_isolation.arn
}

resource "aws_ssm_parameter" "enable_self_isolation_notices" {
  name  = format("%s-enable_self_isolation_notices", module.labels.id)
  type  = "String"
  value = var.self_isolation_notices_enabled
}

resource "aws_ssm_parameter" "self_isolation_notices_url" {
  name  = format("%s-self_isolation_notices_url", module.labels.id)
  type  = "String"
  value = aws_sqs_queue.self_isolation.id
}

resource "aws_ssm_parameter" "security_self_isolation_notices_rate_limit_secs" {
  name  = format("%s-security_self_isolation_notices_rate_limit_secs", module.labels.id)
  type  = "String"
  value = var.security_self_isolation_notices_rate_limit_secs
}

resource "aws_ssm_parameter" "settings_lambda" {
  overwrite = true
  name      = format("%ssettings_lambda", local.config_var_prefix)
  type      = "String"
  value     = aws_lambda_function.settings.arn
  tags      = module.labels.tags
}

# ENX Logo params
resource "aws_ssm_parameter" "enx_logo_supported" {
  name  = format("%s-enx_logo_supported", module.labels.id)
  type  = "String"
  value = var.enx_logo_supported
}

# Exposure Test Types
resource "aws_ssm_parameter" "allowed_test_types" {
  name  = format("%s-allowed_test_types", module.labels.id)
  type  = "String"
  value = var.allowed_test_types
}

# #########################################
# Optional parameters - These exist for some instances
# #########################################
resource "aws_ssm_parameter" "arcgis_url" {
  count     = contains(var.optional_parameters_to_include, "arcgis_url") ? 1 : 0
  overwrite = true
  name      = format("%sarcgis_url", local.config_var_prefix)
  type      = "String"
  value     = var.arcgis_url
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "callback_email_notifications_sns_arn" {
  count     = local.enable_callback_email_notifications_count
  overwrite = true
  name      = format("%scallback_email_notifications_sns_arn", local.config_var_prefix)
  type      = "String"
  value     = join("", aws_sns_topic.callback_email_notifications.*.arn)
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "daily_registrations_reporter_email_subject" {
  count     = contains(var.optional_parameters_to_include, "daily_registrations_reporter_email_subject") ? 1 : 0
  overwrite = true
  name      = format("%sdaily_registrations_reporter_email_subject", local.config_var_prefix)
  type      = "String"
  value     = var.daily_registrations_reporter_email_subject
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "daily_registrations_reporter_sns_arn" {
  count     = contains(var.optional_parameters_to_include, "daily_registrations_reporter_sns_arn") ? 1 : 0
  overwrite = true
  name      = format("%sdaily_registrations_reporter_sns_arn", local.config_var_prefix)
  type      = "String"
  value     = join("", aws_sns_topic.daily_registrations_reporter.*.arn)
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "issue_proxy_url" {
  count     = contains(var.optional_parameters_to_include, "issue_proxy_url") ? 1 : 0
  overwrite = true
  name      = format("%sissue_proxy_url", local.config_var_prefix)
  type      = "String"
  value     = var.issue_proxy_url
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "security_allow_no_token" {
  overwrite = true
  name      = format("%ssecurity_allow_no_token", local.config_var_prefix)
  type      = "String"
  value     = var.allow_no_token
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "security_callback_rate_limit_request_count" {
  count     = contains(var.optional_parameters_to_include, "security_callback_rate_limit_request_count") ? 1 : 0
  overwrite = true
  name      = format("%ssecurity_callback_rate_limit_request_count", local.config_var_prefix)
  type      = "String"
  value     = var.callback_rate_limit_request_count
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "security_callback_rate_limit_secs" {
  count     = contains(var.optional_parameters_to_include, "security_callback_rate_limit_secs") ? 1 : 0
  overwrite = true
  name      = format("%ssecurity_callback_rate_limit_secs", local.config_var_prefix)
  type      = "String"
  value     = var.callback_rate_limit_secs
  tags      = module.labels.tags
}

resource "aws_ssm_parameter" "verify_proxy_url" {
  count     = contains(var.optional_parameters_to_include, "verify_proxy_url") ? 1 : 0
  overwrite = true
  name      = format("%sverify_proxy_url", local.config_var_prefix)
  type      = "String"
  value     = var.verify_proxy_url
  tags      = module.labels.tags
}
