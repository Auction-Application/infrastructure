locals {
  source_location_path = "main.go"
}

locals {
  single_upload_binary_name  = "bootstrap"
  single_upload_binary_path  = "./bin/${local.single_upload_binary_name}"
  single_upload_src_path     = "${path.module}/lambda/lambda-exec/single-file-completion/main.go"
  single_upload_archive_path = "${path.module}/lambda/lambda-exec/single-file-completion/bin/${local.single_upload_binary_name}.zip"
  single_upload_working_dir  = "./lambda/lambda-exec/single-file-completion"
}

locals {
  multi_upload_binary_name  = "bootstrap"
  multi_upload_binary_path  = "./bin/${local.multi_upload_binary_name}"
  multi_upload_src_path     = "${path.module}/lambda/lambda-exec/multipart-completion/main.go"
  multi_upload_archive_path = "${path.module}/lambda/lambda-exec/multipart-completion/bin/${local.multi_upload_binary_name}.zip"
  multi_upload_working_dir  = "./lambda/lambda-exec/multipart-completion"
}

