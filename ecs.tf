# #########################################
# ECS Cluster
# #########################################
resource "aws_ecs_cluster" "services" {
  name = module.labels.id
  tags = module.labels.tags

  setting {
    name  = "containerInsights"
    value = var.enable_ecs_container_insights ? "enabled" : "disabled"
  }
}