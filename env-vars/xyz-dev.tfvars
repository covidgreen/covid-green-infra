# Misc
aws_region  = "eu-west-1"
dns_profile = "xyz-dev"
environment = "dev"
profile     = "xyz-dev"

# RDS Settings
rds_backup_retention = 3

# R53 Settings
api_dns         = "api.dev.somewhere.com"
push_dns        = "push.dev.somewhere.com"
cognito_dns     = "dev.somewhere.com"
route53_zone    = "somewhere.com"
wildcard_domain = "*.somewhere.com"

# API & Lambda - Settings & Env vars
exposure_schedule      = "cron(0/5 * * * ? *)"
log_level              = "info"
settings_schedule      = "cron(0 * * * ? *)"
token_lifetime_mins    = "1440"
verify_rate_limit_secs = "2"
