resource "aws_ssm_parameter" "enable_self_isolation_notices" {
  name  = "${module.labels.id}-enable_self_isolation_notices"
  type  = "String"
  value = var.self_isolation_notices_enabled
}

resource "aws_ssm_parameter" "self_isolation_notices_url" {
  name  = "${module.labels.id}-self_isolation_notices_url"
  type  = "String"
  value = var.self_isolation_notices_url
}
