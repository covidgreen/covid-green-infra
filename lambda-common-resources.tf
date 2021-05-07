module "lambda_sg" {
  source      = "./modules/security-group"
  open_egress = true
  name        = "${module.labels.id}-lambda-stats"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  tags        = module.labels.tags
}

resource "aws_security_group_rule" "lambda_ingress" {
  description       = "Allows backend services to accept connections from ALB"
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = module.lambda_sg.id
}

resource "aws_security_group_rule" "lambda_egress_vpc" {
  description       = "Allows outbound connections to VPC CIDR block"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = module.lambda_sg.id
}

resource "aws_security_group_rule" "lambda_egress_endpoints" {
  description       = "Allows outbound connections to VPC S3 endpoint"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  prefix_list_ids   = [module.vpc.vpc_endpoint_s3_pl_id]
  security_group_id = module.lambda_sg.id
}