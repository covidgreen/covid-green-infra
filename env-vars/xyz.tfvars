# Misc
full_name = "Covoid XYZ"
namespace = "xyz"

# Optional lambdas to include
optional_lambdas_to_include = []

# Optional parameters and secrets to include
optional_parameters_to_include = []
optional_secrets_to_include    = ["sms"]

# RDS Settings
rds_db_name = "xyz"

# Services attributes
app_bundle_id        = "net.somewhere.covid"
code_charset         = "ABCDEFGHJKMNPQRTUVWXYZ2346789"
code_lifetime_mins   = "1440"
default_country_code = "IRL"
default_region       = "IE"
enable_callback      = "false"
enable_check_in      = "false"
native_regions       = "IE"
sms_region           = "eu-west-1"
sms_sender           = "XYZ"
sms_template         = "You can now share your COVID data with the XYZ. Your code is $${code}."
