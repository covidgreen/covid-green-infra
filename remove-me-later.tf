## REMOVE THESE AFTER APPLIES ON ALL ENVS
## We keep this to allow the transition to be made in the state file, if we renamed the plan would balk indicating a missing provider
provider "aws" {
  alias   = "us"
  region  = "us-east-1"
  profile = var.profile
}

provider "aws" {
  alias   = "root"
  region  = var.aws_region
  profile = var.dns_profile
}


## We keep this till we have applied all the way to prod and state files are updated
provider "template" {
  version = "~> 2.1"
}


## Need to do a sequence to remove
## 	To remove we needed to add explicit depends_on
##	Apply on all envs
##	After the apply on all envs we can remove this and it should remove successfully
## Was getting this error
##	Error: Cycle: module.this.aws_api_gateway_stage.live, module.this.aws_api_gateway_resource.api_healthcheck (destroy), module.this.aws_api_gateway_method.api_healthcheck_get (destroy), module.this.aws_api_gateway_deployment.live, module.this.aws_api_gateway_deployment.live (destroy deposed 754a6586), module.this.aws_api_gateway_integration.api_healthcheck_get_integration (destroy)
## /api/healthcheck
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
