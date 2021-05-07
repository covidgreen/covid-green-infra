# #########################################
# Secrets - These will already exist
# #########################################
data "aws_secretsmanager_secret_version" "api_gateway_header" {
  secret_id = "${local.config_var_prefix}header-x-secret"
}

data "aws_secretsmanager_secret_version" "device_check" {
  secret_id = "${local.config_var_prefix}device-check"
}

data "aws_secretsmanager_secret_version" "encrypt" {
  secret_id = "${local.config_var_prefix}encrypt"
}

data "aws_secretsmanager_secret_version" "exposures" {
  secret_id = "${local.config_var_prefix}exposures"
}

data "aws_secretsmanager_secret_version" "jwt" {
  secret_id = "${local.config_var_prefix}jwt"
}

data "aws_secretsmanager_secret_version" "rds" {
  secret_id = "${local.config_var_prefix}rds"
}

data "aws_secretsmanager_secret_version" "admin_push_service_token" {
  secret_id = "${local.config_var_prefix}admin-push-service-token"
}

data "aws_secretsmanager_secret_version" "google_maps_api_key" {
  secret_id = "${local.config_var_prefix}google-maps-api-key"
}

data "aws_secretsmanager_secret_version" "rds_read_only" {
  secret_id = "${local.config_var_prefix}rds-read-only"
}

data "aws_secretsmanager_secret_version" "rds_read_write" {
  secret_id = "${local.config_var_prefix}rds-read-write"
}

data "aws_secretsmanager_secret_version" "rds_read_write_create" {
  secret_id = "${local.config_var_prefix}rds-read-write-create"
}

data "aws_secretsmanager_secret_version" "verify" {
  secret_id = "${local.config_var_prefix}verify"
}

# #########################################
# Optional secrets - These exist for some instances
# #########################################

data "aws_secretsmanager_secret_version" "notice" {
  count     = contains(var.optional_secrets_to_include, "notice") ? 1 : 0
  secret_id = format("%snotice", local.config_var_prefix)
}

data "aws_secretsmanager_secret_version" "quicksight_dashboard" {
  count     = contains(var.optional_secrets_to_include, "quicksight-dashboard") ? 1 : 0
  secret_id = format("%squicksight-dashboard", local.config_var_prefix)
}

data "aws_secretsmanager_secret_version" "cct" {
  count     = contains(var.optional_secrets_to_include, "cct") ? 1 : 0
  secret_id = "${local.config_var_prefix}cct"
}

data "aws_secretsmanager_secret_version" "cso" {
  count     = contains(var.optional_secrets_to_include, "cso") ? 1 : 0
  secret_id = "${local.config_var_prefix}cso"
}

data "aws_secretsmanager_secret_version" "interop" {
  count     = contains(var.optional_secrets_to_include, "interop") ? 1 : 0
  secret_id = "${local.config_var_prefix}interop"
}

data "aws_secretsmanager_secret_version" "sms" {
  count     = contains(var.optional_secrets_to_include, "sms") ? 1 : 0
  secret_id = "${local.config_var_prefix}sms"
}

data "aws_secretsmanager_secret_version" "verify_proxy" {
  count     = contains(var.optional_secrets_to_include, "verify-proxy") ? 1 : 0
  secret_id = "${local.config_var_prefix}verify-proxy"
}
