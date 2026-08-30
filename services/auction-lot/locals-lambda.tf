locals {
  source_location_path = "main.go"
  binary_name          = "bootstrap"
}

locals {
  single_upload_binary_path  = "./bin/${local.binary_name}"
  single_upload_src_bin_path = "${path.module}/lambda/lambda-exec/single-file-completion/bin/${local.binary_name}"
  single_upload_archive_path = "${path.module}/lambda/lambda-exec/single-file-completion/bin/${local.binary_name}.zip"
  single_upload_working_dir  = "./lambda/lambda-exec/single-file-completion"
}

locals {
  multi_upload_binary_path  = "./bin/${local.binary_name}"
  multi_upload_src_bin_path = "${path.module}/lambda/lambda-exec/multipart-completion/bin/${local.binary_name}"
  multi_upload_archive_path = "${path.module}/lambda/lambda-exec/multipart-completion/bin/${local.binary_name}.zip"
  multi_upload_working_dir  = "./lambda/lambda-exec/multipart-completion"
}

