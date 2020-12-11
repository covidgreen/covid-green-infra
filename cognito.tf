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
  domain          = format("%s-login.%s", module.labels.id, var.route53_zone)
  user_pool_id    = aws_cognito_user_pool.admin_user_pool.id
  certificate_arn = aws_acm_certificate.wildcard_cert_us[0].arn
}

### This  is needed by cognito to add domain informations
resource "aws_route53_record" "root_record" {
  provider = aws.dns
  name     = var.route53_zone
  type     = "A"
  zone_id  = data.aws_route53_zone.primary[0].id
  records  = ["1.1.1.1"]
  ttl      = 300
}

resource "aws_route53_record" "auth-cognito-A" {
  provider = aws.dns
  name     = aws_cognito_user_pool_domain.main.domain
  type     = "A"
  zone_id  = data.aws_route53_zone.primary[0].id
  alias {
    evaluate_target_health = false
    name                   = aws_cognito_user_pool_domain.main.cloudfront_distribution_arn
    # This zone_id is fixed
    zone_id = "Z2FDTNDATAQYW2"
  }

  depends_on = [
    aws_route53_record.root_record
  ]
}

resource "aws_cognito_user_group" "settings_read" {
  name         = "settings-read"
  user_pool_id = aws_cognito_user_pool.admin_user_pool.id
}

resource "aws_cognito_user_group" "settings_write" {
  name         = "settings-write"
  user_pool_id = aws_cognito_user_pool.admin_user_pool.id
}

resource "aws_cognito_user_group" "otc-send" {
  name         = "otc-send"
  user_pool_id = aws_cognito_user_pool.admin_user_pool.id
}

resource "aws_cognito_user_group" "qr-admin" {
  name         = "qr-admin"
  user_pool_id = aws_cognito_user_pool.admin_user_pool.id
}

resource "aws_cognito_user_group" "qr-user" {
  name         = "qr-user"
  user_pool_id = aws_cognito_user_pool.admin_user_pool.id
}

resource "aws_cognito_user_group" "manage_users" {
  name         = "manage-users"
  user_pool_id = aws_cognito_user_pool.admin_user_pool.id
}
