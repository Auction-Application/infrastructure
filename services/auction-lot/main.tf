resource "aws_s3_bucket" "auction_lot_bucket" {
  bucket        = "auction-lot-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "s3_delegate_access_to_s3_access-points" {
  bucket = aws_s3_bucket.auction_lot_bucket.id
  policy = data.aws_iam_policy_document.delegate_access_to_s3_access-points_policy_document.json

}

resource "aws_s3_access_point" "auction_lot_service_access_point" {
  bucket = aws_s3_bucket.auction_lot_bucket.id
  name   = "auction-lot-service-access-point"
}

resource "aws_s3control_access_point_policy" "auction_lot_service_access_point_policy" {
  access_point_arn = aws_s3_access_point.auction_lot_service_access_point.arn
  policy           = data.aws_iam_policy_document.auction_lot_service_access_point_policy_document.json
}

resource "aws_s3_bucket_cors_configuration" "auction_lot_images_cors" {
  bucket = aws_s3_bucket.auction_lot_bucket.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 1800
  }
}
