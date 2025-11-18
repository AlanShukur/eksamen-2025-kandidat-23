provider "aws" {
  region = var.aws_region
}

# Selve bucketen
resource "aws_s3_bucket" "analysis" {
  bucket = var.bucket_name
}

# Lifecycle-konfigurasjon for midlertidige filer
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.analysis.id

  rule {
    id     = "temporary-files-lifecycle"
    status = "Enabled"

    # Gjelder kun filer under mappen/prefix "midlertidig/"
    filter {
      prefix = "midlertidig/"
    }

    # Flytt til billigere lagringsklasse etter X dager
    transition {
      days          = var.temp_files_transition_days
      storage_class = "GLACIER"
    }

    # Slett midlertidige filer etter Y dager
    expiration {
      days = var.temp_files_expiration_days
    }
  }
}
