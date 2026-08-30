resource "terraform_data" "function_binary_singlefile" {
  provisioner "local-exec" {
    command     = "GOOS=linux GOARCH=amd64 CGO_ENABLED=0 GOFLAGS=-trimpath go build -mod=readonly -ldflags='-s -w' -o ${local.single_upload_binary_path} ${local.source_location_path}"
    working_dir = local.single_upload_working_dir
  }
}


data "archive_file" "function_archive_singlefile" {
  depends_on  = [terraform_data.function_binary_singlefile]
  type        = "zip"
  source_file = local.single_upload_src_path
  output_path = local.single_upload_archive_path
}

resource "aws_lambda_function" "singlefile_lambda_fn" {
  filename         = local.single_upload_archive_path
  function_name    = "poll-singlefileupload-event"
  role             = aws_iam_role.lambda_role_singlefile.arn
  handler          = "bootstrap"
  runtime          = "provided.al2023"
  description      = "poll single file upload completion event"
  source_code_hash = data.archive_file.function_archive_singlefile.output_base64sha256
  timeout          = 30
}


resource "aws_lambda_event_source_mapping" "singlefile_map" {
  event_source_arn                   = aws_sqs_queue.s3_events_singlepart_queue.arn
  function_name                      = aws_lambda_function.singlefile_lambda_fn.arn
  batch_size                         = 12
  maximum_batching_window_in_seconds = 1
  function_response_types            = ["ReportBatchItemFailures"]

  scaling_config {
    maximum_concurrency = 500
  }
}

resource "aws_iam_role" "lambda_role_singlefile" {
  name               = "lambda-execution-role-singlefile"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_sqs_policy_singlefile_docx" {
  version = "2012-10-17"
  statement {
    sid    = "accessToSingleFileEventsSqsQueue"
    effect = "Allow"
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
    ]
    resources = [aws_sqs_queue.s3_events_singlepart_queue.arn]
  }


}

resource "aws_iam_policy" "lambda_sqs_policy_singlefile" {
  name        = "lambda-sqs-singlefile"
  path        = "/"
  description = "This policy gives access to singlefile queue"
  policy      = data.aws_iam_policy_document.lambda_sqs_policy_singlefile_docx.json
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_singlefile_policy_sqs" {
  role       = aws_iam_role.lambda_role_singlefile.name
  policy_arn = aws_iam_policy.lambda_sqs_policy_singlefile.arn
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_singlefile_policy_logs" {
  role       = aws_iam_role.lambda_role_singlefile.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

