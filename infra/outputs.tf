output "backup_bucket_name" {
  value = aws_s3_bucket.hugo_backup.bucket
}
output "backup_bucket_arn" {
  value = aws_s3_bucket.hugo_backup.arn
}
output "aws_region" {
  value = var.aws_region
}
