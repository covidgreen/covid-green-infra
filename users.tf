resource "aws_iam_user" "ci_user" {
  name = "${module.labels.id}-ci"
  tags = module.labels.tags
}

resource "aws_iam_user_policy_attachment" "ci_user_ecr" {
  user       = aws_iam_user.ci_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

data "aws_iam_policy_document" "ci_user" {
  statement {
    actions = [
      "ecs:UpdateService",
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition",
      "ecs:DescribeServices",
      "cloudwatch:PutDashboard",
      "cloudwatch:GetDashboard"
    ]

    resources = [
      "*",
    ]
  }
  statement {
    actions = [
      "s3:ListBucket",
      "s3:PutObject"
    ]

    resources = [
      aws_s3_bucket.assets.arn,
      format("%s/*", aws_s3_bucket.assets.arn)
    ]
  }

  statement {
    actions = [
      "route53:GetChange"
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "ci_user_lambda" {
  statement {
    actions = [
      "lambda:UpdateFunctionCode",
      "lambda:ListAliases",
      "lambda:ListVersionsByFunction",
      "lambda:UpdateAlias"
    ]

    resources = [
      "*",
    ]
  }
}


data "aws_iam_policy_document" "ci_user_pass_role" {
  statement {
    actions = [
      "iam:PassRole"
    ]

    resources = [
      aws_iam_role.admin_ecs_task_role.arn,
      aws_iam_role.admin_ecs_task_execution.arn,
      aws_iam_role.api_ecs_task_role.arn,
      aws_iam_role.api_ecs_task_execution.arn,
      aws_iam_role.push_ecs_task_role.arn,
      aws_iam_role.push_ecs_task_execution.arn
    ]
  }
}

resource "aws_iam_user_policy" "ci_user_general" {
  name   = "${module.labels.id}-ci-user"
  user   = aws_iam_user.ci_user.name
  policy = data.aws_iam_policy_document.ci_user.json
}

resource "aws_iam_user_policy" "ci_user_lambda" {
  name   = "${module.labels.id}-ci-user_lambda"
  user   = aws_iam_user.ci_user.name
  policy = data.aws_iam_policy_document.ci_user_lambda.json
}

resource "aws_iam_user_policy" "ci_user_pass_role" {
  name   = "${module.labels.id}-ci-user_pass_role"
  user   = aws_iam_user.ci_user.name
  policy = data.aws_iam_policy_document.ci_user_pass_role.json
}


