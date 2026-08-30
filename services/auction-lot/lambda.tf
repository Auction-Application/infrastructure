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













