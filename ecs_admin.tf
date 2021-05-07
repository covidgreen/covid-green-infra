# #########################################
# ECS General Resources
# #########################################
data "aws_iam_policy_document" "admin_ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "admin_ecs_task_execution" {
  name               = "${module.labels.id}-admin-task-exec-role"
  assume_role_policy = data.aws_iam_policy_document.admin_ecs_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "admin_ecs_task_execution" {
  role       = aws_iam_role.admin_ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "admin_ecs_task_role" {
  name               = "${module.labels.id}-admin-task-role"
  assume_role_policy = data.aws_iam_policy_document.admin_ecs_assume_role_policy.json
}

data "aws_iam_policy_document" "admin_ecs_task_policy" {
  statement {
    actions = ["ssm:GetParameter", "ssm:GetParameters"]
    resources = concat([
      aws_ssm_parameter.admin_cognito_user_pool_id.arn,
      aws_ssm_parameter.admin_cognito_region.arn,
      aws_ssm_parameter.admin_cors_origin.arn,
      aws_ssm_parameter.admin_host.arn,
      aws_ssm_parameter.admin_port.arn,
      aws_ssm_parameter.db_database.arn,
      aws_ssm_parameter.db_host.arn,
      aws_ssm_parameter.db_pool_size.arn,
      aws_ssm_parameter.db_port.arn,
      aws_ssm_parameter.db_reader_host.arn,
      aws_ssm_parameter.db_ssl.arn,
      aws_ssm_parameter.log_level.arn,
      aws_ssm_parameter.push_service_url.arn,
      aws_ssm_parameter.settings_lambda.arn,
      ],
      aws_ssm_parameter.security_callback_rate_limit_request_count.*.arn,
    aws_ssm_parameter.security_callback_rate_limit_secs.*.arn)
  }

  statement {
    actions = ["secretsmanager:GetSecretValue"]
    resources = concat([
      data.aws_secretsmanager_secret_version.rds_read_only.arn,
      data.aws_secretsmanager_secret_version.rds_read_write.arn,
      data.aws_secretsmanager_secret_version.admin_push_service_token.arn,
      data.aws_secretsmanager_secret_version.google_maps_api_key.arn,      
    ], data.aws_secretsmanager_secret_version.quicksight_dashboard.*.arn)
  }
  statement {
    actions = [
      "cognito-idp:AdminCreateUser",
      "cognito-idp:AdminDeleteUser",
      "cognito-idp:AdminListGroupsForUser",
      "cognito-idp:AdminAddUserToGroup",
      "cognito-idp:AdminRemoveUserFromGroup",
      "cognito-idp:ListUsers"
    ]
    resources = [
      aws_cognito_user_pool.admin_user_pool.arn
    ]
  }

  statement {
    actions = ["lambda:InvokeFunction"]
    resources = [
      aws_lambda_function.settings.arn
    ]
  }


}

resource "aws_iam_policy" "admin_ecs_task_policy" {
  name   = "${module.labels.id}-ecs-admin-task-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.admin_ecs_task_policy.json
}

resource "aws_iam_role_policy_attachment" "admin_ecs_task_policy" {
  role       = aws_iam_role.admin_ecs_task_role.name
  policy_arn = aws_iam_policy.admin_ecs_task_policy.arn
}

# #########################################
# admin Service
# #########################################
resource "aws_ecs_task_definition" "admin" {
  family                   = "${module.labels.id}-admin"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.admin_services_task_cpu
  memory                   = var.admin_services_task_memory
  execution_role_arn       = aws_iam_role.admin_ecs_task_execution.arn
  task_role_arn            = aws_iam_role.admin_ecs_task_role.arn
  tags                     = module.labels.tags

  container_definitions = templatefile(format("%s/templates/admin_service_task_definition.tpl", path.module),
    {
      admin_image_uri   = local.ecs_admin_image
      aws_region        = var.aws_region
      config_var_prefix = local.config_var_prefix
      listening_port    = var.admin_listening_port
      logs_service_name = aws_cloudwatch_log_group.admin.name
      log_group_region  = var.aws_region
      node_env          = "production"
  })
}

resource "aws_ecs_service" "admin" {
  name            = "${module.labels.id}-admin"
  cluster         = aws_ecs_cluster.services.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.admin.arn
  desired_count   = var.admin_service_desired_count

  network_configuration {
    security_groups = ["${module.admin_sg.id}"]
    subnets         = module.vpc.private_subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.admin.id
    container_name   = "admin"
    container_port   = var.admin_listening_port
  }

  depends_on = [
    aws_lb_listener.admin_http
  ]

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count
    ]
  }
}

module "admin_autoscale" {
  source                              = "./modules/ecs-autoscale-service"
  ecs_cluster_resource_name           = aws_ecs_cluster.services.name
  service_resource_name               = aws_ecs_service.admin.name
  ecs_autoscale_max_instances         = var.admin_ecs_autoscale_max_instances
  ecs_autoscale_min_instances         = var.admin_ecs_autoscale_min_instances
  ecs_autoscale_scale_down_adjustment = var.admin_ecs_autoscale_scale_down_adjustment
  ecs_autoscale_scale_up_adjustment   = var.admin_ecs_autoscale_scale_up_adjustment
  ecs_as_cpu_high_threshold           = var.admin_cpu_high_threshold
  ecs_as_cpu_low_threshold            = var.admin_cpu_low_threshold
  ecs_as_mem_high_threshold           = var.admin_mem_high_threshold
  ecs_as_mem_low_threshold            = var.admin_mem_low_threshold
  tags                                = module.labels.tags
}

# #########################################
# admin log group
# #########################################
resource "aws_cloudwatch_log_group" "admin" {
  name              = "${module.labels.id}-admin"
  retention_in_days = var.logs_retention_days
  tags              = module.labels.tags

  lifecycle {
    create_before_destroy = true
  }
}

# #########################################
# Security group - Allow all access from LB
# #########################################
module "admin_sg" {
  source      = "./modules/security-group"
  open_egress = true
  name        = "${module.labels.id}-admin"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  tags        = module.labels.tags
}

resource "aws_security_group_rule" "admin_ingress_http" {
  description              = "Allows backend services to accept connections from ALB"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = module.alb_admin_sg.id
  security_group_id        = module.admin_sg.id
}
