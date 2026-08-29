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

resource "aws_s3_bucket_notification" "auction_image_upload" {
  bucket = aws_s3_bucket.auction_lot_bucket.id

  queue {
    id        = "single-image-upload-event"
    queue_arn = aws_sqs_queue.s3_events_singlepart_queue.arn
    events    = ["s3:ObjectCreated:Put", "s3:ObjectCreated:Post"]
  }
  queue {
    id        = "multipart-image-upload-event"
    queue_arn = aws_sqs_queue.s3_events_multipart_queue.arn
    events    = ["s3:ObjectCreated:CompleteMultipartUpload"]
  }

}


resource "aws_sqs_queue" "s3_events_singlepart_queue" {
  name                       = "s3-events-singlepart-queue"
  delay_seconds              = 0
  visibility_timeout_seconds = 181
  max_message_size           = 262144
  message_retention_seconds  = 345600
  receive_wait_time_seconds  = 2
}



resource "aws_sqs_queue_redrive_policy" "singlepart_redrive-policy" {
  queue_url = aws_sqs_queue.s3_events_singlepart_queue.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.s3_events_singlepart_dlq.arn
    maxReceiveCount     = 4
  })
}

resource "aws_sqs_queue" "s3_events_multipart_queue" {
  name                       = "s3-events-multipart-queue"
  delay_seconds              = 0
  visibility_timeout_seconds = 181
  max_message_size           = 262144
  message_retention_seconds  = 345600
  receive_wait_time_seconds  = 2
}

resource "aws_sqs_queue_redrive_policy" "multipart_redrive-policy" {
  queue_url = aws_sqs_queue.s3_events_multipart_queue.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.s3_events_multipart_dlq.arn
    maxReceiveCount     = 4
  })
}

resource "aws_sqs_queue" "s3_events_singlepart_dlq" {
  name                       = "s3-events-singlepart-dlq"
  delay_seconds              = 0
  visibility_timeout_seconds = 45
  max_message_size           = 262144
  message_retention_seconds  = 1209600
  receive_wait_time_seconds  = 5
}


resource "aws_sqs_queue_redrive_allow_policy" "s3_events_singlepart_dlq_policy" {
  queue_url = aws_sqs_queue.s3_events_singlepart_dlq.id
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.s3_events_singlepart_queue.arn]
  })
}

resource "aws_sqs_queue" "s3_events_multipart_dlq" {
  name                       = "s3-events-multipart-dlq"
  delay_seconds              = 0
  visibility_timeout_seconds = 45
  max_message_size           = 262144
  message_retention_seconds  = 1209600
  receive_wait_time_seconds  = 5
}

resource "aws_sqs_queue_redrive_allow_policy" "s3_events_multipart_dlq_policy" {
  queue_url = aws_sqs_queue.s3_events_multipart_dlq.id
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.s3_events_multipart_queue.arn]
  })
}

resource "aws_sqs_queue_policy" "auction_image_singlepart_s3_events_access" {
  queue_url = aws_sqs_queue.s3_events_singlepart_queue.id
  policy    = data.aws_iam_policy_document.auction_image_s3_events_sqs_policy.json
}

resource "aws_sqs_queue_policy" "auction_image_multipart_s3_events_access" {
  queue_url = aws_sqs_queue.s3_events_multipart_queue.id
  policy    = data.aws_iam_policy_document.auction_image_s3_events_sqs_policy.json
}





