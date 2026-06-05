data "aws_iam_policy_document" "delegate_access_to_s3_access-points_policy_document" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "*"
    ]

    resources = [
      "${aws_s3_bucket.auction_lot_bucket.arn}",
      "${aws_s3_bucket.auction_lot_bucket.arn}/*"

    ]
    condition {
      test     = "StringEquals"
      values   = ["433154991296"]
      variable = "s3:DataAccessPointAccount"
    }
  }
}

data "aws_iam_policy_document" "auction_lot_service_access_point_policy_document" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::433154991296:root"]
    }
    actions = [
      "s3:GetObject",
      "s3:PutObject"

    ]

    resources = [
      "${aws_s3_access_point.auction_lot_service_access_point.arn}/object/*"
    ]
  }
}
