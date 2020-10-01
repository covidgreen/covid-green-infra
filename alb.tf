# #########################################
# ALB API
# #########################################
module "alb_api_sg" {
  source      = "./modules/security-group"
  open_egress = true
  name        = format("%s-%s", module.labels.id, "alb-api")
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  tags        = module.labels.tags
}

resource "aws_security_group_rule" "alb_api_http_ingress" {
  description       = "Allows connection on port 80 from anywhere"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.alb_api_sg.id
}

resource "aws_lb" "api" {
  name                             = format("%s-%s", module.labels.id, "api")
  internal                         = false
  subnets                          = module.vpc.public_subnets
  security_groups                  = ["${module.alb_api_sg.id}"]
  enable_cross_zone_load_balancing = true
  enable_http2                     = true
  ip_address_type                  = "dualstack"
  enable_deletion_protection       = true
  tags                             = module.labels.tags

  access_logs {
    bucket  = module.alb_logs.aws_logs_bucket
    prefix  = "api"
    enabled = true
  }
}

resource "aws_lb_target_group" "api" {
  name                 = format("%s-%s", module.labels.id, "api")
  port                 = var.api_listening_port
  protocol             = var.api_listening_protocol
  vpc_id               = module.vpc.vpc_id
  deregistration_delay = 10
  target_type          = "ip"

  health_check {
    path                = var.health_check_path
    matcher             = var.health_check_matcher
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  tags = module.labels.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "api_http" {
  load_balancer_arn = aws_lb.api.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Forbidden"
      status_code  = "403"
    }
  }
}

resource "aws_lb_listener_rule" "header_check" {
  listener_arn = aws_lb_listener.api_http.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  condition {
    http_header {
      http_header_name = "X-Routing-Secret"
      values           = [jsondecode(data.aws_secretsmanager_secret_version.api_gateway_header.secret_string)["header-secret"]]
    }
  }
}

# #########################################
# ALB Push
# #########################################
module "alb_push_sg" {
  source      = "./modules/security-group"
  open_egress = true
  name        = format("%s-%s", module.labels.id, "alb-push")
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  tags        = module.labels.tags
}

resource "aws_security_group_rule" "alb_push_https_ingress_all" {
  description       = "Allows connection on port 443 from anywhere"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.push_allowed_ips
  security_group_id = module.alb_push_sg.id
}

resource "aws_lb" "push" {
  name                             = format("%s-%s", module.labels.id, "push")
  internal                         = false
  subnets                          = module.vpc.public_subnets
  security_groups                  = ["${module.alb_push_sg.id}"]
  enable_cross_zone_load_balancing = true
  enable_http2                     = true
  ip_address_type                  = "dualstack"
  enable_deletion_protection       = true
  tags                             = module.labels.tags

  access_logs {
    bucket  = module.alb_logs.aws_logs_bucket
    prefix  = "push"
    enabled = true
  }
}

resource "aws_lb_target_group" "push" {
  name                 = format("%s-%s", module.labels.id, "push")
  port                 = var.push_listening_port
  protocol             = var.push_listening_protocol
  vpc_id               = module.vpc.vpc_id
  target_type          = "ip"
  deregistration_delay = "10"

  health_check {
    path                = var.health_check_path
    matcher             = var.health_check_matcher
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  tags = module.labels.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "push_https" {
  load_balancer_arn = aws_lb.push.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.lb_push_ssl_policy
  certificate_arn   = local.alb_push_certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.push.id
    type             = "forward"
  }
}

# #########################################
# ALB logs - single bucket for both ALBs each with their own prefix
# #########################################
module "alb_logs" {
  source  = "trussworks/logs/aws"
  version = "8.2.0"

  alb_logs_prefixes       = ["api", "push"]
  allow_alb               = true
  default_allow           = false
  force_destroy           = true
  region                  = var.aws_region
  s3_bucket_name          = format("%s-alb-logs", module.labels.id)
  s3_log_bucket_retention = var.logs_retention_days
  tags                    = module.labels.tags
}
