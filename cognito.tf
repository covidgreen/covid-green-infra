locals {
  enable_domain_count = var.enable_dns && var.enable_certificates ? 1 : 0
}
resource "aws_cognito_user_pool" "admin_user_pool" {
  name                = "${module.labels.id}-admin-userpool"
  username_attributes = ["email"]
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name                         = "${module.labels.id}-admin-userpool-client"
  user_pool_id                 = aws_cognito_user_pool.admin_user_pool.id
  allowed_oauth_flows          = ["code", "implicit"]
  callback_urls                = ["http://localhost"]
  default_redirect_uri         = "http://localhost"
  allowed_oauth_scopes         = ["phone", "email", "openid", "profile", "aws.cognito.signin.user.admin"]
  supported_identity_providers = ["COGNITO"]
}

resource "aws_cognito_user_pool_domain" "main" {
  count           = local.enable_domain_count
  domain          = format("%s-login.%s", module.labels.id, var.cognito_dns)
  user_pool_id    = aws_cognito_user_pool.admin_user_pool.id
  certificate_arn = aws_acm_certificate.wildcard_cert_us[0].arn
}

resource "aws_route53_record" "auth_cognito_A_record" {
  count    = local.enable_domain_count
  provider = aws.dns
  name     = aws_cognito_user_pool_domain.main[0].domain
  type     = "A"
  zone_id  = data.aws_route53_zone.primary[0].id
  alias {
    evaluate_target_health = false
    name                   = aws_cognito_user_pool_domain.main[0].cloudfront_distribution_arn
    # This zone_id is fixed
    zone_id = "Z2FDTNDATAQYW2"
  }
}

resource "aws_cognito_user_group" "settings_read" {
  name         = "settings-read"
  user_pool_id = aws_cognito_user_pool.admin_user_pool.id
}

resource "aws_cognito_user_group" "settings_write" {
  name         = "settings-write"
  user_pool_id = aws_cognito_user_pool.admin_user_pool.id
}

resource "aws_cognito_user_group" "otc_send" {
  name         = "otc-send"
  user_pool_id = aws_cognito_user_pool.admin_user_pool.id
}

resource "aws_cognito_user_group" "qr_admin" {
  name         = "qr-admin"
  user_pool_id = aws_cognito_user_pool.admin_user_pool.id
}

resource "aws_cognito_user_group" "qr_user" {
  name         = "qr-user"
  user_pool_id = aws_cognito_user_pool.admin_user_pool.id
}

resource "aws_cognito_user_group" "manage_users" {
  name         = "manage-users"
  user_pool_id = aws_cognito_user_pool.admin_user_pool.id
}

resource "aws_cognito_user_group" "dashboard-read" {
  name         = "dashboard-read"
  user_pool_id = aws_cognito_user_pool.admin_user_pool.id
}