variable "bucket_name" {
  description = "Navn på S3 bucket for analyseresultater"
  type        = string
  default     = "kandidat-23-data"
}

variable "aws_region" {
  description = "AWS region for infrastruktur"
  type        = string
  default     = "eu-west-1"
}

variable "temp_files_transition_days" {
  description = "Antall dager før midlertidige filer flyttes til billigere lagringsklasse"
  type        = number
  default     = 30
}

variable "temp_files_expiration_days" {
  description = "Antall dager før midlertidige filer slettes permanent"
  type        = number
  default     = 90
}
