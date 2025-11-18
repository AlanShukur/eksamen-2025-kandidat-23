output "bucket_name" {
  description = "Navn på S3-bucket for analyseresultater"
  value       = aws_s3_bucket.analysis.bucket
}

output "bucket_region" {
  description = "Region for bucketen"
  value       = var.aws_region
}

output "lifecycle_rule_id" {
  description = "ID til lifecycle-regelen for midlertidige filer"
  value       = aws_s3_bucket_lifecycle_configuration.this.rule[0].id
}
