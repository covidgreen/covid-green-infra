# #########################################
# KMS
# #########################################
data "aws_iam_policy_document" "kms" {
  statement {
    actions = ["kms:*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    resources = ["*"]
  }
}

resource "aws_kms_alias" "sqs" {
  name          = format("alias/%s-sqs", module.labels.id)
  target_key_id = aws_kms_key.sqs.key_id
}

resource "aws_kms_alias" "sns" {
  name          = format("alias/%s-sns", module.labels.id)
  target_key_id = aws_kms_key.sns.key_id
}

resource "aws_kms_key" "sqs" {
  description = "KMS key for SQS"
  policy      = data.aws_iam_policy_document.kms.json
  tags        = module.labels.tags
}

resource "aws_kms_key" "sns" {
  description = "KMS key for SNS"
  policy      = data.aws_iam_policy_document.kms.json
  tags        = module.labels.tags
}
