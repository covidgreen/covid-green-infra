# #########################################
# API Gateway REST API
# #########################################
resource "aws_api_gateway_rest_api" "main" {
  name                     = "${module.labels.id}-gw"
  minimum_compression_size = var.api_gateway_minimum_compression_size
  tags                     = module.labels.tags

  binary_media_types = concat([
    "application/zip",
    "application/octet-stream",
    "*/*",
  ], var.api_gateway_customizations_binary_types)

  endpoint_configuration {
    types = ["EDGE"]
  }
}

## custom domain name
resource "aws_api_gateway_domain_name" "main" {
  count           = local.gateway_api_domain_name_count
  certificate_arn = local.gateway_api_certificate_arn
  domain_name     = var.api_dns
  security_policy = "TLS_1_2"

  depends_on = [
    aws_acm_certificate.wildcard_cert_us,
    aws_acm_certificate_validation.wildcard_cert_us
  ]
}

## execution role with s3 access
data "aws_iam_policy_document" "gw_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "gateway" {
  name               = "${module.labels.id}-gw"
  assume_role_policy = data.aws_iam_policy_document.gw_assume_role_policy.json
}

data "aws_iam_policy_document" "gw" {
  statement {
    actions = ["s3:*", "logs:*"]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "gw" {
  name   = "${module.labels.id}-gw"
  path   = "/"
  policy = data.aws_iam_policy_document.gw.json
}

resource "aws_iam_role_policy_attachment" "gw" {
  role       = aws_iam_role.gateway.name
  policy_arn = aws_iam_policy.gw.arn
}

# #########################################
# API Gateway resources and mapping
# #########################################
## /
resource "aws_api_gateway_method" "root" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_rest_api.main.root_resource_id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "root" {
  rest_api_id          = aws_api_gateway_rest_api.main.id
  resource_id          = aws_api_gateway_rest_api.main.root_resource_id
  http_method          = aws_api_gateway_method.root.http_method
  timeout_milliseconds = var.api_gateway_timeout_milliseconds
  type                 = "MOCK"
  request_templates = {
    "application/json" = jsonencode({ statusCode : 404 })
  }
}

resource "aws_api_gateway_method_response" "root" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_rest_api.main.root_resource_id
  http_method = aws_api_gateway_method.root.http_method
  status_code = "404"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "root" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_rest_api.main.root_resource_id
  http_method = aws_api_gateway_method.root.http_method
  status_code = "404"
}
## /isolation
resource "aws_api_gateway_resource" "isolation" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "isolation"
}
resource "aws_api_gateway_method" "isolation_get" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.isolation.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "isolation_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.isolation.id
  http_method             = aws_api_gateway_method.isolation_get.http_method
  timeout_milliseconds    = var.api_gateway_timeout_milliseconds
  integration_http_method = "GET"
  type                    = "AWS"
  uri                     = format("arn:aws:apigateway:%s:s3:path/%s/isolation/index.html", var.aws_region, aws_s3_bucket.assets.id)
  credentials             = aws_iam_role.gateway.arn
}
resource "aws_api_gateway_method_response" "isolation_get_method_response" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.isolation.id
  http_method = aws_api_gateway_method.isolation_get.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Content-Length"            = false,
    "method.response.header.Content-Type"              = false,
    "method.response.header.Cache-Control"             = true,
    "method.response.header.Pragma"                    = true,
    "method.response.header.Strict-Transport-Security" = true
    "method.response.header.X-Frame-Options"           = true
  }
}

resource "aws_api_gateway_integration_response" "isolation_get_integration_response" {
  rest_api_id       = aws_api_gateway_rest_api.main.id
  resource_id       = aws_api_gateway_resource.isolation.id
  http_method       = aws_api_gateway_method.isolation_get.http_method
  selection_pattern = aws_api_gateway_method_response.isolation_get_method_response.status_code
  status_code       = aws_api_gateway_method_response.isolation_get_method_response.status_code
  response_parameters = {
    "method.response.header.Content-Length"            = "integration.response.header.Content-Length",
    "method.response.header.Content-Type"              = "integration.response.header.Content-Type",
    "method.response.header.Cache-Control"             = "'no-store'",
    "method.response.header.Pragma"                    = "'no-cache'",
    "method.response.header.Strict-Transport-Security" = format("'max-age=%s; includeSubDomains'", var.hsts_max_age)
  }
}



## /isolation/{key+}

resource "aws_api_gateway_resource" "isolation_key" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.isolation.id
  path_part   = "{key+}"
}

resource "aws_api_gateway_method" "isolation_key_get" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.isolation_key.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = false
  request_parameters = {
    "method.request.path.key" = true
  }
}
resource "aws_api_gateway_integration" "isolation_key_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.isolation_key.id
  http_method             = aws_api_gateway_method.isolation_key_get.http_method
  timeout_milliseconds    = var.api_gateway_timeout_milliseconds
  integration_http_method = "GET"
  type                    = "AWS"
  uri                     = format("arn:aws:apigateway:%s:s3:path/%s/isolation/{key}", var.aws_region, aws_s3_bucket.assets.id)
  credentials             = aws_iam_role.gateway.arn
  request_parameters = {
    "integration.request.path.key" = "method.request.path.key",
  }
}

resource "aws_api_gateway_method_response" "isolation_key_get_method_response" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.isolation_key.id
  http_method = aws_api_gateway_method.isolation_key_get.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Content-Length"            = false,
    "method.response.header.Content-Type"              = false,
    "method.response.header.Cache-Control"             = true,
    "method.response.header.Pragma"                    = true,
    "method.response.header.Strict-Transport-Security" = true
  }
}

resource "aws_api_gateway_integration_response" "isolation_key_get_integration_response" {
  rest_api_id       = aws_api_gateway_rest_api.main.id
  resource_id       = aws_api_gateway_resource.isolation_key.id
  http_method       = aws_api_gateway_method.isolation_key_get.http_method
  selection_pattern = aws_api_gateway_method_response.isolation_key_get_method_response.status_code
  status_code       = aws_api_gateway_method_response.isolation_key_get_method_response.status_code
  response_parameters = {
    "method.response.header.Content-Length"            = "integration.response.header.Content-Length",
    "method.response.header.Content-Type"              = "integration.response.header.Content-Type",
    "method.response.header.Cache-Control"             = "'no-store'",
    "method.response.header.Pragma"                    = "'no-cache'",
    "method.response.header.Strict-Transport-Security" = format("'max-age=%s; includeSubDomains'", var.hsts_max_age)
  }
}

## /admin-ui
resource "aws_api_gateway_resource" "admin_ui" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "admin-ui"
}
resource "aws_api_gateway_method" "admin_ui_get" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.admin_ui.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "admin_ui_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.admin_ui.id
  http_method             = aws_api_gateway_method.admin_ui_get.http_method
  timeout_milliseconds    = var.api_gateway_timeout_milliseconds
  integration_http_method = "GET"
  type                    = "AWS"
  uri                     = format("arn:aws:apigateway:%s:s3:path/%s/admin-ui/index.html", var.aws_region, aws_s3_bucket.assets.id)
  credentials             = aws_iam_role.gateway.arn
}

resource "aws_api_gateway_method_response" "admin_ui_get" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.admin_ui.id
  http_method = aws_api_gateway_method.admin_ui_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Content-Length"            = true,
    "method.response.header.Content-Type"              = true,
    "method.response.header.Cache-Control"             = true,
    "method.response.header.Pragma"                    = true,
    "method.response.header.Strict-Transport-Security" = true
  }
}

resource "aws_api_gateway_integration_response" "admin_ui_get_integration" {
  rest_api_id       = aws_api_gateway_rest_api.main.id
  resource_id       = aws_api_gateway_resource.admin_ui.id
  http_method       = aws_api_gateway_method.admin_ui_get.http_method
  selection_pattern = aws_api_gateway_method_response.admin_ui_get.status_code
  status_code       = aws_api_gateway_method_response.admin_ui_get.status_code
  response_parameters = {
    "method.response.header.Content-Length"            = "integration.response.header.Content-Length",
    "method.response.header.Content-Type"              = "integration.response.header.Content-Type",
    "method.response.header.Cache-Control"             = "'no-store'",
    "method.response.header.Pragma"                    = "'no-cache'",
    "method.response.header.Strict-Transport-Security" = format("'max-age=%s; includeSubDomains'", var.hsts_max_age)
  }
}

## /admin-ui/{key+}

resource "aws_api_gateway_resource" "admin_ui_key" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.admin_ui.id
  path_part   = "{key+}"
}

resource "aws_api_gateway_method" "admin_ui_key_get" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.admin_ui_key.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = false
  request_parameters = {
    "method.request.path.key" = true
  }
}
resource "aws_api_gateway_integration" "admin_ui_key_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.admin_ui_key.id
  http_method             = aws_api_gateway_method.admin_ui_key_get.http_method
  timeout_milliseconds    = var.api_gateway_timeout_milliseconds
  integration_http_method = "GET"
  type                    = "AWS"
  uri                     = format("arn:aws:apigateway:%s:s3:path/%s/admin-ui/{key}", var.aws_region, aws_s3_bucket.assets.id)
  credentials             = aws_iam_role.gateway.arn
  request_parameters = {
    "integration.request.path.key" = "method.request.path.key",
  }
}

resource "aws_api_gateway_method_response" "admin_ui_key_get_method_response" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.admin_ui_key.id
  http_method = aws_api_gateway_method.admin_ui_key_get.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Content-Length"            = false,
    "method.response.header.Content-Type"              = false,
    "method.response.header.Cache-Control"             = true,
    "method.response.header.Pragma"                    = true,
    "method.response.header.Strict-Transport-Security" = true
  }
}

resource "aws_api_gateway_integration_response" "admin_ui_key_get_integration_response" {
  rest_api_id       = aws_api_gateway_rest_api.main.id
  resource_id       = aws_api_gateway_resource.admin_ui_key.id
  http_method       = aws_api_gateway_method.admin_ui_key_get.http_method
  selection_pattern = aws_api_gateway_method_response.admin_ui_key_get_method_response.status_code
  status_code       = aws_api_gateway_method_response.admin_ui_key_get_method_response.status_code
  response_parameters = {
    "method.response.header.Content-Length"            = "integration.response.header.Content-Length",
    "method.response.header.Content-Type"              = "integration.response.header.Content-Type",
    "method.response.header.Cache-Control"             = "'no-store'",
    "method.response.header.Pragma"                    = "'no-cache'",
    "method.response.header.Strict-Transport-Security" = format("'max-age=%s; includeSubDomains'", var.hsts_max_age)
  }
}

## /admin
resource "aws_api_gateway_resource" "admin" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "admin"
}

resource "aws_api_gateway_authorizer" "admin_authorizer" {
  name          = "${module.labels.id}-cognito-authorizer"
  rest_api_id   = aws_api_gateway_rest_api.main.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [aws_cognito_user_pool.admin_user_pool.arn]
}


## /admin/{proxy}
resource "aws_api_gateway_resource" "admin_proxy" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.admin.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "admin_proxy_options" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.admin_proxy.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "admin_proxy_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.admin_proxy.id
  http_method             = aws_api_gateway_method.admin_proxy_options.http_method
  integration_http_method = "OPTIONS"
  type                    = "HTTP_PROXY"
  uri                     = format("http://%s/{proxy}", aws_lb.admin.dns_name)

  request_parameters = {
    "integration.request.path.proxy"              = "method.request.path.proxy",
    "integration.request.header.X-Routing-Secret" = "'${jsondecode(data.aws_secretsmanager_secret_version.api_gateway_header.secret_string)["header-secret"]}'",
    "integration.request.header.X-Forwarded-For"  = "'nope'"
  }
}

resource "aws_api_gateway_method" "admin_proxy_any" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.admin_proxy.id
  http_method      = "ANY"
  authorization    = "COGNITO_USER_POOLS"
  authorizer_id    = aws_api_gateway_authorizer.admin_authorizer.id
  api_key_required = false
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "admin_proxy_any_integration" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.admin_proxy.id
  http_method             = aws_api_gateway_method.admin_proxy_any.http_method
  timeout_milliseconds    = var.api_gateway_timeout_milliseconds
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = format("http://%s/{proxy}", aws_lb.admin.dns_name)
  request_parameters = {
    "integration.request.path.proxy"              = "method.request.path.proxy",
    "integration.request.header.X-Routing-Secret" = "'${jsondecode(data.aws_secretsmanager_secret_version.api_gateway_header.secret_string)["header-secret"]}'",
    "integration.request.header.X-Forwarded-For"  = "'nope'"
  }
}

resource "aws_api_gateway_method_response" "admin_proxy_any" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.admin_proxy.id
  http_method = aws_api_gateway_method.admin_proxy_any.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.access-control-allow-headers" = true,
    "method.response.header.access-control-allow-methods" = true,
    "method.response.header.access-control-allow-origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "admin_proxy_any_integration" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.admin_proxy.id
  http_method = aws_api_gateway_method.admin_proxy_any.http_method
  status_code = aws_api_gateway_method_response.admin_proxy_any.status_code

  depends_on = [ 
    aws_api_gateway_integration.admin_proxy_any_integration
   ]
}


## /enx/{key+}
resource "aws_api_gateway_resource" "enx_root" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "enx"
}

resource "aws_api_gateway_resource" "enx_proxy" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.enx_root.id
  path_part   = "{key+}"
}

resource "aws_api_gateway_method" "enx_proxy_get" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.enx_proxy.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = false
  request_parameters = {
    "method.request.path.key" = true
  }
}

resource "aws_api_gateway_integration" "enx_proxy_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.enx_proxy.id
  http_method             = aws_api_gateway_method.enx_proxy_get.http_method
  timeout_milliseconds    = var.api_gateway_timeout_milliseconds
  integration_http_method = "GET"
  type                    = "AWS"
  uri                     = format("arn:aws:apigateway:%s:s3:path/%s/enx/{key}", var.aws_region, aws_s3_bucket.assets.id)
  credentials             = aws_iam_role.gateway.arn
  request_parameters = {
    "integration.request.path.key" = "method.request.path.key",
  }
}

resource "aws_api_gateway_method_response" "enx_proxy_get" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.enx_proxy.id
  http_method = aws_api_gateway_method.enx_proxy_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Content-Length"            = false,
    "method.response.header.Content-Type"              = false,
    "method.response.header.Cache-Control"             = true,
    "method.response.header.Pragma"                    = true,
    "method.response.header.Strict-Transport-Security" = true
  }
}

resource "aws_api_gateway_integration_response" "enx_proxy_get_integration" {
  rest_api_id       = aws_api_gateway_rest_api.main.id
  resource_id       = aws_api_gateway_resource.enx_proxy.id
  http_method       = aws_api_gateway_method.enx_proxy_get.http_method
  selection_pattern = aws_api_gateway_method_response.enx_proxy_get.status_code
  status_code       = aws_api_gateway_method_response.enx_proxy_get.status_code
  response_parameters = {
    "method.response.header.Content-Length"            = "integration.response.header.Content-Length",
    "method.response.header.Content-Type"              = "integration.response.header.Content-Type",
    "method.response.header.Cache-Control"             = "'no-store'",
    "method.response.header.Pragma"                    = "'no-cache'",
    "method.response.header.Strict-Transport-Security" = format("'max-age=%s; includeSubDomains'", var.hsts_max_age)
  }
}

## /api
resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "api"
}

## /api/{proxy}
resource "aws_api_gateway_resource" "api_proxy" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "api_proxy_options" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.api_proxy.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "api_proxy_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.api_proxy.id
  http_method             = aws_api_gateway_method.api_proxy_options.http_method
  integration_http_method = "OPTIONS"
  type                    = "HTTP_PROXY"
  uri                     = format("http://%s/{proxy}", aws_lb.api.dns_name)

  request_parameters = {
    "integration.request.path.proxy"              = "method.request.path.proxy",
    "integration.request.header.X-Routing-Secret" = "'${jsondecode(data.aws_secretsmanager_secret_version.api_gateway_header.secret_string)["header-secret"]}'",
    "integration.request.header.X-Forwarded-For"  = "'nope'"
  }
}

resource "aws_api_gateway_method" "api_proxy_any" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.api_proxy.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = false
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "api_proxy_any_integration" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.api_proxy.id
  http_method             = aws_api_gateway_method.api_proxy_any.http_method
  timeout_milliseconds    = var.api_gateway_timeout_milliseconds
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = format("http://%s/{proxy}", aws_lb.api.dns_name)
  request_parameters = {
    "integration.request.path.proxy"              = "method.request.path.proxy",
    "integration.request.header.X-Routing-Secret" = "'${jsondecode(data.aws_secretsmanager_secret_version.api_gateway_header.secret_string)["header-secret"]}'",
    "integration.request.header.X-Forwarded-For"  = "'nope'"
  }
}

resource "aws_api_gateway_method_response" "api_proxy_any" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.api_proxy.id
  http_method = aws_api_gateway_method.api_proxy_any.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.access-control-allow-headers" = true,
    "method.response.header.access-control-allow-methods" = true,
    "method.response.header.access-control-allow-origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "api_proxy_any_integration" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.api_proxy.id
  http_method = aws_api_gateway_method.api_proxy_any.http_method
  status_code = aws_api_gateway_method_response.api_proxy_any.status_code
}

## /api/settings
resource "aws_api_gateway_resource" "api_settings" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "settings"
}

resource "aws_api_gateway_method" "api_settings_get" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.api_settings.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "api_settings_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.api_settings.id
  http_method             = aws_api_gateway_method.api_settings_get.http_method
  timeout_milliseconds    = var.api_gateway_timeout_milliseconds
  integration_http_method = "GET"
  type                    = "AWS"
  uri                     = format("arn:aws:apigateway:%s:s3:path/%s/settings.json", var.aws_region, aws_s3_bucket.assets.id)
  credentials             = aws_iam_role.gateway.arn
}

resource "aws_api_gateway_method_response" "api_settings_get" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.api_settings.id
  http_method = aws_api_gateway_method.api_settings_get.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Content-Length"            = false,
    "method.response.header.Content-Type"              = false,
    "method.response.header.Cache-Control"             = true,
    "method.response.header.Pragma"                    = true,
    "method.response.header.Strict-Transport-Security" = true
  }
}

resource "aws_api_gateway_integration_response" "api_settings_get_integration" {
  rest_api_id       = aws_api_gateway_rest_api.main.id
  resource_id       = aws_api_gateway_resource.api_settings.id
  http_method       = aws_api_gateway_method.api_settings_get.http_method
  selection_pattern = aws_api_gateway_method_response.api_settings_get.status_code
  status_code       = aws_api_gateway_method_response.api_settings_get.status_code
  response_parameters = {
    "method.response.header.Content-Length"            = "integration.response.header.Content-Length",
    "method.response.header.Content-Type"              = "integration.response.header.Content-Type",
    "method.response.header.Cache-Control"             = "'no-store'",
    "method.response.header.Pragma"                    = "'no-cache'",
    "method.response.header.Strict-Transport-Security" = format("'max-age=%s; includeSubDomains'", var.hsts_max_age)
  }
}

## /api/settings/exposures
resource "aws_api_gateway_resource" "api_settings_exposures" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.api_settings.id
  path_part   = "exposures"
}

resource "aws_api_gateway_method" "api_settings_exposures_get" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.api_settings_exposures.id
  http_method      = "GET"
  authorization    = "CUSTOM"
  authorizer_id    = aws_api_gateway_authorizer.main.id
  api_key_required = false
}

resource "aws_api_gateway_integration" "api_settings_exposures_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.api_settings_exposures.id
  http_method             = aws_api_gateway_method.api_settings_exposures_get.http_method
  timeout_milliseconds    = var.api_gateway_timeout_milliseconds
  integration_http_method = "GET"
  type                    = "AWS"
  uri                     = format("arn:aws:apigateway:%s:s3:path/%s/exposures.json", var.aws_region, aws_s3_bucket.assets.id)
  credentials             = aws_iam_role.gateway.arn
}

resource "aws_api_gateway_method_response" "api_settings_exposures_get" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.api_settings_exposures.id
  http_method = aws_api_gateway_method.api_settings_exposures_get.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Content-Length"            = false,
    "method.response.header.Content-Type"              = false,
    "method.response.header.Cache-Control"             = true,
    "method.response.header.Pragma"                    = true,
    "method.response.header.Strict-Transport-Security" = true
  }
}

resource "aws_api_gateway_integration_response" "api_settings_exposures_get_integration" {
  rest_api_id       = aws_api_gateway_rest_api.main.id
  resource_id       = aws_api_gateway_resource.api_settings_exposures.id
  http_method       = aws_api_gateway_method.api_settings_exposures_get.http_method
  selection_pattern = aws_api_gateway_method_response.api_settings_exposures_get.status_code
  status_code       = aws_api_gateway_method_response.api_settings_exposures_get.status_code
  response_parameters = {
    "method.response.header.Content-Length"            = "integration.response.header.Content-Length",
    "method.response.header.Content-Type"              = "integration.response.header.Content-Type",
    "method.response.header.Cache-Control"             = "'no-store'",
    "method.response.header.Pragma"                    = "'no-cache'",
    "method.response.header.Strict-Transport-Security" = format("'max-age=%s; includeSubDomains'", var.hsts_max_age)
  }
}

## /api/settings/language
resource "aws_api_gateway_resource" "api_settings_language" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.api_settings.id
  path_part   = "language"
}

resource "aws_api_gateway_method" "api_settings_language_get" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.api_settings_language.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "api_settings_language_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.api_settings_language.id
  http_method             = aws_api_gateway_method.api_settings_language_get.http_method
  timeout_milliseconds    = var.api_gateway_timeout_milliseconds
  integration_http_method = "GET"
  type                    = "AWS"
  uri                     = format("arn:aws:apigateway:%s:s3:path/%s/language.json", var.aws_region, aws_s3_bucket.assets.id)
  credentials             = aws_iam_role.gateway.arn
}

resource "aws_api_gateway_method_response" "api_settings_language_get" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.api_settings_language.id
  http_method = aws_api_gateway_method.api_settings_language_get.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Content-Length"            = false,
    "method.response.header.Content-Type"              = false,
    "method.response.header.Cache-Control"             = true,
    "method.response.header.Pragma"                    = true,
    "method.response.header.Strict-Transport-Security" = true
  }
}

resource "aws_api_gateway_integration_response" "api_settings_language_get_integration" {
  rest_api_id       = aws_api_gateway_rest_api.main.id
  resource_id       = aws_api_gateway_resource.api_settings_language.id
  http_method       = aws_api_gateway_method.api_settings_language_get.http_method
  selection_pattern = aws_api_gateway_method_response.api_settings_language_get.status_code
  status_code       = aws_api_gateway_method_response.api_settings_language_get.status_code
  response_parameters = {
    "method.response.header.Content-Length"            = "integration.response.header.Content-Length",
    "method.response.header.Content-Type"              = "integration.response.header.Content-Type",
    "method.response.header.Cache-Control"             = "'no-store'",
    "method.response.header.Pragma"                    = "'no-cache'",
    "method.response.header.Strict-Transport-Security" = format("'max-age=%s; includeSubDomains'", var.hsts_max_age)
  }
}

## /api/stats
resource "aws_api_gateway_resource" "api_stats" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "stats"
}

resource "aws_api_gateway_method" "api_stats_get" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.api_stats.id
  http_method      = "GET"
  authorization    = "CUSTOM"
  authorizer_id    = aws_api_gateway_authorizer.main.id
  api_key_required = false
}

resource "aws_api_gateway_integration" "api_stats_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.api_stats.id
  http_method             = aws_api_gateway_method.api_stats_get.http_method
  timeout_milliseconds    = var.api_gateway_timeout_milliseconds
  integration_http_method = "GET"
  type                    = "AWS"
  uri                     = format("arn:aws:apigateway:%s:s3:path/%s/stats.json", var.aws_region, aws_s3_bucket.assets.id)
  credentials             = aws_iam_role.gateway.arn
}

resource "aws_api_gateway_method_response" "api_stats_get" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.api_stats.id
  http_method = aws_api_gateway_method.api_stats_get.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Content-Length"            = false,
    "method.response.header.Content-Type"              = false,
    "method.response.header.Cache-Control"             = true,
    "method.response.header.Pragma"                    = true,
    "method.response.header.Strict-Transport-Security" = true
  }
}

resource "aws_api_gateway_integration_response" "api_stats_get_integration" {
  rest_api_id       = aws_api_gateway_rest_api.main.id
  resource_id       = aws_api_gateway_resource.api_stats.id
  http_method       = aws_api_gateway_method.api_stats_get.http_method
  selection_pattern = aws_api_gateway_method_response.api_stats_get.status_code
  status_code       = aws_api_gateway_method_response.api_stats_get.status_code
  response_parameters = {
    "method.response.header.Content-Length"            = "integration.response.header.Content-Length",
    "method.response.header.Content-Type"              = "integration.response.header.Content-Type",
    "method.response.header.Cache-Control"             = "'no-store'",
    "method.response.header.Pragma"                    = "'no-cache'",
    "method.response.header.Strict-Transport-Security" = format("'max-age=%s; includeSubDomains'", var.hsts_max_age)
  }
}

## /api/data
resource "aws_api_gateway_resource" "api_data" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "data"
}

## /api/data/exposures
resource "aws_api_gateway_resource" "api_data_exposures" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.api_data.id
  path_part   = "exposures"
}

## /api/data/exposures/{item}
resource "aws_api_gateway_resource" "api_data_exposures_item" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.api_data_exposures.id
  path_part   = "{item+}"
}

resource "aws_api_gateway_method" "api_data_exposures_item_get" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.api_data_exposures_item.id
  http_method      = "GET"
  authorization    = "CUSTOM"
  authorizer_id    = aws_api_gateway_authorizer.main.id
  api_key_required = false
  request_parameters = {
    "method.request.path.item" = true
  }
}

resource "aws_api_gateway_integration" "api_data_exposures_item_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.api_data_exposures_item.id
  http_method             = aws_api_gateway_method.api_data_exposures_item_get.http_method
  timeout_milliseconds    = var.api_gateway_timeout_milliseconds
  integration_http_method = "GET"
  type                    = "AWS"
  uri                     = format("arn:aws:apigateway:%s:s3:path/%s/exposures/{item}", var.aws_region, aws_s3_bucket.assets.id)
  credentials             = aws_iam_role.gateway.arn
  request_parameters = {
    "integration.request.path.item" = "method.request.path.item"
  }
}

resource "aws_api_gateway_method_response" "api_data_exposures_item_get_success" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.api_data_exposures_item.id
  http_method = aws_api_gateway_method.api_data_exposures_item_get.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty",
    "application/zip"  = "Empty"
  }
  response_parameters = {
    "method.response.header.Content-Length"            = false,
    "method.response.header.Content-Type"              = false,
    "method.response.header.Cache-Control"             = true,
    "method.response.header.Pragma"                    = true,
    "method.response.header.Strict-Transport-Security" = true
  }
}

resource "aws_api_gateway_method_response" "api_data_exposures_item_get_error" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.api_data_exposures_item.id
  http_method = aws_api_gateway_method.api_data_exposures_item_get.http_method
  status_code = "404"
}

resource "aws_api_gateway_integration_response" "api_data_exposures_item_get_integration_success" {
  rest_api_id       = aws_api_gateway_rest_api.main.id
  resource_id       = aws_api_gateway_resource.api_data_exposures_item.id
  http_method       = aws_api_gateway_method.api_data_exposures_item_get.http_method
  status_code       = aws_api_gateway_method_response.api_data_exposures_item_get_success.status_code
  selection_pattern = aws_api_gateway_method_response.api_data_exposures_item_get_success.status_code
  response_parameters = {
    "method.response.header.Content-Length"            = "integration.response.header.Content-Length",
    "method.response.header.Content-Type"              = "integration.response.header.Content-Type",
    "method.response.header.Cache-Control"             = "'no-store'",
    "method.response.header.Pragma"                    = "'no-cache'",
    "method.response.header.Strict-Transport-Security" = format("'max-age=%s; includeSubDomains'", var.hsts_max_age)
  }
}

resource "aws_api_gateway_integration_response" "api_data_exposures_item_get_integration_error" {
  rest_api_id       = aws_api_gateway_rest_api.main.id
  resource_id       = aws_api_gateway_resource.api_data_exposures_item.id
  http_method       = aws_api_gateway_method.api_data_exposures_item_get.http_method
  status_code       = aws_api_gateway_method_response.api_data_exposures_item_get_error.status_code
  selection_pattern = "[45][0-9]{2}"
  response_templates = {
    "application/json" : jsonencode({
      message = "Not found"
    }),
    "application/zip" : jsonencode({
      message = "Not found"
    })
  }
}

## /api/healthcheck - GET
resource "aws_api_gateway_resource" "api_healthcheck" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "healthcheck"
}

resource "aws_api_gateway_method" "api_healthcheck_get" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.api_healthcheck.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = false

  depends_on = [aws_api_gateway_resource.api_healthcheck]
}

resource "aws_api_gateway_integration" "api_healthcheck_get_integration" {
  rest_api_id          = aws_api_gateway_rest_api.main.id
  resource_id          = aws_api_gateway_resource.api_healthcheck.id
  http_method          = aws_api_gateway_method.api_healthcheck_get.http_method
  passthrough_behavior = "WHEN_NO_TEMPLATES"
  type                 = "MOCK"
  request_templates = {
    "application/json" = jsonencode({
      statusCode = 204
    })
  }

  depends_on = [aws_api_gateway_method.api_healthcheck_get]
}

resource "aws_api_gateway_method_response" "api_healthcheck_get" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.api_healthcheck.id
  http_method = aws_api_gateway_method.api_healthcheck_get.http_method
  status_code = "204"

  depends_on = [aws_api_gateway_method.api_healthcheck_get]
}

resource "aws_api_gateway_integration_response" "api_healthcheck_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.api_healthcheck.id
  http_method = aws_api_gateway_method.api_healthcheck_get.http_method
  status_code = aws_api_gateway_method_response.api_healthcheck_get.status_code

  depends_on = [aws_api_gateway_integration.api_healthcheck_get_integration]
}

## /api/healthcheck - HEAD
resource "aws_api_gateway_method" "api_healthcheck_head" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.api_healthcheck.id
  http_method      = "HEAD"
  authorization    = "NONE"
  api_key_required = false

  depends_on = [aws_api_gateway_resource.api_healthcheck]
}

resource "aws_api_gateway_integration" "api_healthcheck_head_integration" {
  rest_api_id          = aws_api_gateway_rest_api.main.id
  resource_id          = aws_api_gateway_resource.api_healthcheck.id
  http_method          = aws_api_gateway_method.api_healthcheck_head.http_method
  passthrough_behavior = "WHEN_NO_TEMPLATES"
  type                 = "MOCK"
  request_templates = {
    "application/json" = jsonencode({
      statusCode = 204
    })
  }

  depends_on = [aws_api_gateway_method.api_healthcheck_head]
}

resource "aws_api_gateway_method_response" "api_healthcheck_head" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.api_healthcheck.id
  http_method = aws_api_gateway_method.api_healthcheck_head.http_method
  status_code = "204"

  depends_on = [aws_api_gateway_method.api_healthcheck_head]
}

resource "aws_api_gateway_integration_response" "api_healthcheck_head_integration" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.api_healthcheck.id
  http_method = aws_api_gateway_method.api_healthcheck_head.http_method
  status_code = aws_api_gateway_method_response.api_healthcheck_head.status_code

  depends_on = [aws_api_gateway_integration.api_healthcheck_head_integration]
}

# #########################################
# API Gateway Deployment
# #########################################
locals {
  gw_stage_description = format("%s-%s", filemd5("${path.module}/gateway.tf"), var.api_gateway_customizations_md5)
}

resource "aws_api_gateway_deployment" "live" {
  rest_api_id       = aws_api_gateway_rest_api.main.id
  stage_description = local.gw_stage_description

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.root,
    aws_api_gateway_integration.isolation_get_integration,
    aws_api_gateway_integration.isolation_key_get_integration,
    aws_api_gateway_integration.admin_ui_get_integration,
    aws_api_gateway_integration.admin_ui_key_get_integration,
    aws_api_gateway_integration.admin_proxy_options_integration,
    aws_api_gateway_integration.admin_proxy_any_integration,
    aws_api_gateway_integration.enx_proxy_get_integration,
    aws_api_gateway_integration.api_proxy_options_integration,
    aws_api_gateway_integration.api_proxy_any_integration,
    aws_api_gateway_integration.api_settings_get_integration,
    aws_api_gateway_integration.api_settings_exposures_get_integration,
    aws_api_gateway_integration.api_settings_language_get_integration,
    aws_api_gateway_integration.api_stats_get_integration,
    aws_api_gateway_integration.api_data_exposures_item_get_integration
  ]
}

# Should only have one per account/region - hence it is conditional
resource "aws_api_gateway_account" "gw" {
  count               = local.gateway_api_account_count
  cloudwatch_role_arn = aws_iam_role.gateway.arn
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "${module.labels.id}-gw-access-logs"
  retention_in_days = var.logs_retention_days
}

resource "aws_api_gateway_stage" "live" {
  deployment_id = aws_api_gateway_deployment.live.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = "live"
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format          = "[$context.requestTime] \"$context.httpMethod $context.path $context.protocol\" $context.status [$context.identity.userAgent] $context.responseLength $context.requestId"
  }

  lifecycle {
    ignore_changes = [
      cache_cluster_size
    ]
  }
}

resource "aws_cloudwatch_log_metric_filter" "enx_logo_all_filter" {
  log_group_name = "${module.labels.id}-gw-access-logs"
  name = "${module.labels.id}-enxlogoall-filter"
  pattern = "[time ,method = \"*enx/logo*\", statusCode ,agent=\"*CFNetwork*\"]"
  metric_transformation {
    name = "enxlogoall"
    namespace = "ApiGateway"
    value = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "enx_logo_200_filter" {
  log_group_name = "${module.labels.id}-gw-access-logs"
  name = "${module.labels.id}-enxlogo200-filter"
  pattern = "[time ,method = \"*enx/logo*\", statusCode = 200,agent=\"*CFNetwork*\"]"
  metric_transformation {
    name = "enxlogo200"
    namespace = "ApiGateway"
    value = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "enx_logo_304_filter" {
  log_group_name = "${module.labels.id}-gw-access-logs"
  name = "${module.labels.id}-enxlogo304-filter"
  pattern = "[time ,method = \"*enx/logo*\", statusCode = 304,agent=\"*CFNetwork*\"]"
  metric_transformation {
    name = "enxlogo304"
    namespace = "ApiGateway"
    value = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "enx_logo_settings_filter" {
  log_group_name = "${module.labels.id}-gw-access-logs"
  name = "${module.labels.id}-enxlogosettings-filter"
  pattern = "[time ,method = \"*enx/logo*\", statusCode = 200,agent=\"*Settings*CFNetwork*\"]"
  metric_transformation {
    name = "enxlogosettings"
    namespace = "ApiGateway"
    value = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "enx_logo_enbuddy_filter" {
  log_group_name = "${module.labels.id}-gw-access-logs"
  name = "${module.labels.id}-enxlogoenbuddy-filter"
  pattern = "[time ,method = \"*enx/logo*\", statusCode = 200,agent=\"*HealthENBuddy*CFNetwork*\"]"
  metric_transformation {
    name = "enxlogoenbuddy"
    namespace = "ApiGateway"
    value = "1"
  }
}

resource "aws_api_gateway_method_settings" "settings" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_stage.live.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled        = true
    data_trace_enabled     = true
    logging_level          = "INFO"
    throttling_rate_limit  = var.api_gateway_throttling_rate_limit
    throttling_burst_limit = var.api_gateway_throttling_burst_limit
  }
}

resource "aws_api_gateway_base_path_mapping" "main" {
  count       = local.gateway_api_domain_name_count
  api_id      = aws_api_gateway_rest_api.main.id
  stage_name  = "live"
  domain_name = aws_api_gateway_domain_name.main[0].domain_name
}

resource "aws_api_gateway_authorizer" "main" {
  name                   = "main"
  rest_api_id            = aws_api_gateway_rest_api.main.id
  authorizer_uri         = coalesce(join("", aws_lambda_alias.authorizer_live.*.invoke_arn), aws_lambda_function.authorizer.invoke_arn)
  authorizer_credentials = aws_iam_role.authorizer.arn
}


# #########################################
# Default Responses
# #########################################
resource "aws_api_gateway_gateway_response" "test" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  response_type = "DEFAULT_4XX"

  response_parameters = {
    "gatewayresponse.header.access-control-allow-origin" = "'*'"
  }
}
