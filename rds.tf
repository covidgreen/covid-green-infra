# #########################################
# RDS Cluster
# https://github.com/cloudposse/terraform-aws-rds-cluster
# #########################################
data "aws_iam_policy_document" "rds_enhanced_monitoring" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rds_enhanced_monitoring" {
  count = local.rds_enhanced_monitoring_enabled_count

  assume_role_policy = data.aws_iam_policy_document.rds_enhanced_monitoring.json
  name               = format("%s-rds-enhanced-monitoring", module.labels.id)
  tags               = module.labels.tags
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count = local.rds_enhanced_monitoring_enabled_count

  role       = aws_iam_role.rds_enhanced_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

module "rds_cluster_aurora_postgres" {
  source              = "cloudposse/rds-cluster/aws"
  version             = "0.31.0"
  engine              = "aurora-postgresql"
  cluster_family      = var.rds_cluster_family
  cluster_size        = var.rds_cluster_size
  namespace           = var.namespace
  stage               = var.environment
  name                = "rds"
  admin_user          = jsondecode(data.aws_secretsmanager_secret_version.rds.secret_string)["username"]
  admin_password      = jsondecode(data.aws_secretsmanager_secret_version.rds.secret_string)["password"]
  db_name             = var.rds_db_name
  db_port             = "5432"
  instance_type       = var.rds_instance_type
  vpc_id              = module.vpc.vpc_id
  subnets             = concat(module.vpc.intra_subnets, module.vpc.private_subnets)
  storage_encrypted   = true
  skip_final_snapshot = var.environment == "dev" ? true : false
  backup_window       = "04:00-06:00"
  security_groups     = concat([module.admin_sg.id, module.api_sg.id, module.push_sg.id, module.lambda_sg.id, aws_security_group.quicksight.id], aws_security_group.bastion.*.id)
  retention_period    = var.rds_backup_retention
  deletion_protection = true

  # Use standard perf insights
  performance_insights_enabled = true

  # Enhanced monitoring - is optional
  rds_monitoring_interval = var.rds_enhanced_monitoring_interval
  rds_monitoring_role_arn = join("", aws_iam_role.rds_enhanced_monitoring.*.arn)

  # Put here the snapshot id to recreate the cluster using an existing dataset
  # snapshot_identifier = "SNAPSHOT ID HERE"

  tags = module.labels.tags
}

resource "aws_security_group" "quicksight" {
  name        = "${module.labels.id}-quicksight"
  description = "Allow Quicksight to connect to RDS"
  vpc_id      = module.vpc.vpc_id
  tags = module.labels.tags

    ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    # Can't use security group of RDS as it might cause circular dependency
    cidr_blocks = concat(var.intra_subnets_cidr, var.private_subnets_cidr)
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    # Can't use security group of RDS as it might cause circular dependency
    cidr_blocks = concat(var.intra_subnets_cidr, var.private_subnets_cidr)
  }

}
