# #########################################
# Admins - group with ability to assume a role with privileged access
# #########################################
data "aws_iam_policy_document" "admins_group" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.admins.arn]
  }
}

data "aws_iam_policy_document" "admins_role" {
  statement {
    actions = ["sts:AssumeRole"]

    dynamic condition {
      for_each = var.admins_role_require_mfa ? { 1 : 1 } : {}
      content {
        test     = "Bool"
        variable = "aws:MultiFactorAuthPresent"
        values   = ["true"]
      }
    }

    principals {
      type        = "AWS"
      identifiers = [format("arn:aws:iam::%s:root", data.aws_caller_identity.current.account_id)]
    }
  }
}

resource "aws_iam_group" "admins" {
  name = format("%s-%s", module.labels.id, "admins")
  path = "/"
}

resource "aws_iam_group_policy" "admins" {
  group  = aws_iam_group.admins.id
  name   = format("%s-%s", module.labels.id, "admins")
  policy = data.aws_iam_policy_document.admins_group.json
}

resource "aws_iam_role" "admins" {
  assume_role_policy = data.aws_iam_policy_document.admins_role.json
  name               = format("%s-%s", module.labels.id, "admins")
  tags               = module.labels.tags
}

resource "aws_iam_role_policy_attachment" "admins" {
  role       = aws_iam_role.admins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
