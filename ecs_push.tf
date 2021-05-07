# #########################################
# ECS General Resources
# #########################################
data "aws_iam_policy_document" "push_ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "push_ecs_task_policy" {
  statement {
    actions = ["ssm:GetParameter"]
    resources = concat([
      aws_ssm_parameter.cors_origin.arn,
      aws_ssm_parameter.db_database.arn,
      aws_ssm_parameter.db_host.arn,
      aws_ssm_parameter.db_pool_size.arn,
      aws_ssm_parameter.db_port.arn,
      aws_ssm_parameter.db_reader_host.arn,
      aws_ssm_parameter.db_ssl.arn,
      aws_ssm_parameter.default_country_code.arn,
      aws_ssm_parameter.hsts_max_age.arn,
      aws_ssm_parameter.log_level.arn,
      aws_ssm_parameter.onset_date_mandatory.arn,
      aws_ssm_parameter.push_cors_origin.arn,
      aws_ssm_parameter.push_host.arn,
      aws_ssm_parameter.push_port.arn,
      aws_ssm_parameter.reduced_metrics_whitelist.arn,
      aws_ssm_parameter.security_code_charset.arn,
      aws_ssm_parameter.security_code_length.arn,
      aws_ssm_parameter.security_code_lifetime_mins.arn,
      aws_ssm_parameter.security_code_deeplinks_allowed.arn,
      aws_ssm_parameter.sms_url.arn,
      aws_ssm_parameter.symptom_date_offset.arn,
      aws_ssm_parameter.time_zone.arn,
      aws_ssm_parameter.use_test_date_as_onset_date.arn      
      ],
      aws_ssm_parameter.issue_proxy_url.*.arn,
      aws_ssm_parameter.sms_scheduling.*.arn
    )
  }

  statement {
    actions = ["secretsmanager:GetSecretValue"]
    resources = concat([
      data.aws_secretsmanager_secret_version.jwt.arn,
      data.aws_secretsmanager_secret_version.encrypt.arn,
      data.aws_secretsmanager_secret_version.rds_read_write.arn
      ],
      data.aws_secretsmanager_secret_version.verify_proxy.*.arn
    )
  }

  statement {
    actions = ["kms:Decrypt", "kms:DescribeKey", "kms:Encrypt", "kms:GenerateDataKey", "kms:GenerateDataKey*", "kms:GetPublicKey", "kms:ReEncrypt*"]
    resources = [
      aws_kms_key.sqs.arn
    ]
  }

  statement {
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.sms.arn]
  }
}

resource "aws_iam_role" "push_ecs_task_execution" {
  name               = "${module.labels.id}-push-task-exec-role"
  assume_role_policy = data.aws_iam_policy_document.push_ecs_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "push_ecs_task_execution" {
  role       = aws_iam_role.push_ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "push_ecs_task_role" {
  name               = "${module.labels.id}-push-task-role"
  assume_role_policy = data.aws_iam_policy_document.push_ecs_assume_role_policy.json
}

resource "aws_iam_policy" "push_ecs_task_policy" {
  name   = "${module.labels.id}-ecs-push-task-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.push_ecs_task_policy.json
}

resource "aws_iam_role_policy_attachment" "push_ecs_task_policy" {
  role       = aws_iam_role.push_ecs_task_role.name
  policy_arn = aws_iam_policy.push_ecs_task_policy.arn
}

# #########################################
# Push Service
# #########################################
resource "aws_ecs_task_definition" "push" {
  family                   = "${module.labels.id}-push"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.push_services_task_cpu
  memory                   = var.push_services_task_memory
  execution_role_arn       = aws_iam_role.push_ecs_task_execution.arn
  task_role_arn            = aws_iam_role.push_ecs_task_role.arn
  tags                     = module.labels.tags

  container_definitions = templatefile(format("%s/templates/push_service_task_definition.tpl", path.module),
    {
      aws_region        = var.aws_region
      config_var_prefix = local.config_var_prefix
      image_uri         = local.ecs_push_image
      listening_port    = var.push_listening_port
      logs_service_name = aws_cloudwatch_log_group.push.name
      log_group_region  = var.aws_region
      node_env          = "production"
  })
}

resource "aws_ecs_service" "push" {
  name            = "${module.labels.id}-push"
  cluster         = aws_ecs_cluster.services.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.push.arn
  desired_count   = var.push_service_desired_count

  network_configuration {
    security_groups = ["${module.push_sg.id}"]
    subnets         = module.vpc.private_subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.push.id
    container_name   = "push"
    container_port   = var.push_listening_port
  }

  depends_on = [
    aws_lb_listener.push_https
  ]

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count
    ]
  }
}

module "push_autoscale" {
  source                              = "./modules/ecs-autoscale-service"
  ecs_cluster_resource_name           = aws_ecs_cluster.services.name
  service_resource_name               = aws_ecs_service.push.name
  ecs_autoscale_max_instances         = var.push_ecs_autoscale_max_instances
  ecs_autoscale_min_instances         = var.push_ecs_autoscale_min_instances
  ecs_autoscale_scale_down_adjustment = var.push_ecs_autoscale_scale_down_adjustment
  ecs_autoscale_scale_up_adjustment   = var.push_ecs_autoscale_scale_up_adjustment
  ecs_as_cpu_high_threshold           = var.push_cpu_high_threshold
  ecs_as_cpu_low_threshold            = var.push_cpu_low_threshold
  ecs_as_mem_high_threshold           = var.push_mem_high_threshold
  ecs_as_mem_low_threshold            = var.push_mem_low_threshold
  tags                                = module.labels.tags
}

# #########################################
# API log group
# #########################################
resource "aws_cloudwatch_log_group" "push" {
  name              = "${module.labels.id}-push"
  retention_in_days = var.logs_retention_days
  tags              = module.labels.tags

  lifecycle {
    create_before_destroy = true
  }
}

# #########################################
# Security group - Allow all access from LB
# #########################################
module "push_sg" {
  source      = "./modules/security-group"
  open_egress = true
  name        = "${module.labels.id}-push"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  tags        = module.labels.tags
}

resource "aws_security_group_rule" "push_ingress_http" {
  description              = "Allows push service to accept connections from ALB"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = module.alb_push_sg.id
  security_group_id        = module.push_sg.id
}
