resource "terraform_data" "function_binary_multipart" {
  provisioner "local-exec" {
    command     = "GOOS=linux GOARCH=amd64 CGO_ENABLED=0 GOFLAGS=-trimpath go build -mod=readonly -ldflags='-s -w' -o ${local.multi_upload_binary_path} ${local.source_location_path}"
    working_dir = local.multi_upload_working_dir
  }
}


data "archive_file" "function_archive_multipart" {
  depends_on  = [terraform_data.function_binary_multipart]
  type        = "zip"
  source_file = local.multi_upload_src_bin_path
  output_path = local.multi_upload_archive_path
}

resource "aws_lambda_function" "multipartfile_lambda_fn" {
  filename         = data.archive_file.function_archive_multipart.output_path
  function_name    = "poll-multipartupload-event"
  role             = aws_iam_role.lambda_role_multipartfile.arn
  handler          = "bootstrap"
  runtime          = "provided.al2023"
  description      = "poll multipart file upload completion event"
  source_code_hash = data.archive_file.function_archive_multipart.output_base64sha256
  timeout          = 30
}

resource "aws_lambda_event_source_mapping" "multipartfile_map" {
  event_source_arn                   = aws_sqs_queue.s3_events_multipart_queue.arn
  function_name                      = aws_lambda_function.multipartfile_lambda_fn.arn
  batch_size                         = 12
  maximum_batching_window_in_seconds = 1
  function_response_types            = ["ReportBatchItemFailures"]

  scaling_config {
    maximum_concurrency = 500
  }
}


resource "aws_iam_role" "lambda_role_multipartfile" {
  name               = "lambda-execution-role-multipartfile"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_sqs_policy_multipartfile_docx" {
  version = "2012-10-17"
  statement {
    sid    = "accessToMultipartFileEventsSqsQueue"
    effect = "Allow"
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
    ]
    resources = [aws_sqs_queue.s3_events_multipart_queue.arn]
  }
}

resource "aws_iam_policy" "lambda_sqs_policy_multipartfile" {
  name        = "lambda-sqs-multipartfile"
  path        = "/"
  description = "This policy gives access to multipart queue"
  policy      = data.aws_iam_policy_document.lambda_sqs_policy_multipartfile_docx.json
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_multipartfile_policy_attach" {
  role       = aws_iam_role.lambda_role_multipartfile.name
  policy_arn = aws_iam_policy.lambda_sqs_policy_multipartfile.arn
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_multipartfile_policy_logs" {
  role       = aws_iam_role.lambda_role_multipartfile.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
