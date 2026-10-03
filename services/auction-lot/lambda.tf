data "aws_iam_policy_document" "lambda_assume_role" {
  version = "2012-10-17"
  statement {
    sid    = "assumeRoleForLambda"
    effect = "Allow"
    principals {
      type = "Service"

      identifiers = ["lambda.amazonaws.com"]

    }
    actions = ["sts:AssumeRole"]
  }


}

data "aws_iam_policy_document" "lambda_secret_manager_access_rds_docx" {
  version = "2012-10-17"
  statement {
    sid    = "accessToSecretManagerForRDS"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    # todo rds is in a separate terraform state, use input variable 
    resources = ["arn:aws:secretsmanager:ap-south-1:433154991296:secret:rds!db-b6f333a5-ad18-461d-89b7-3b4a8beddf6c-O4yFgJ"]
  }
}

resource "aws_iam_policy" "lambda_secret_manager_access_rds" {
  name        = "lambda-secret-access-rds"
  path        = "/"
  description = "This policy gives access to secret manager"
  policy      = data.aws_iam_policy_document.lambda_secret_manager_access_rds_docx.json
}













