
-- name: CommitMultiPartUpload :exec
update image_blob_upload_attempts set upload_state='committed' where upload_type='multiUpload' and storage_key= sqlc.arg(storage_key)::uuid and upload_state='pending';