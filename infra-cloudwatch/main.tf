terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

# ================================
# SNS TOPIC
# ================================
resource "aws_sns_topic" "alarm_topic" {
  name = "kandidat23-cloudwatch-alarms"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "email"
  endpoint  = var.alarm_email   # <-- Du setter dette i variables.tf
}

# ================================
# CLOUDWATCH DASHBOARD
# ================================
resource "aws_cloudwatch_dashboard" "sentiment_dashboard" {
  dashboard_name = "kandidat-23-sentiment-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x    = 0,
        y    = 0,
        width  = 12,
        height = 6,

        properties = {
          metrics = [
            ["kandidat-23-sentimentapp", "bedrock.api.latency", { "stat": "Average", "period": 60 }]
          ]
          title = "Bedrock API Latency (ms)"
        }
      },

      {
        type = "metric",
        x    = 0,
        y    = 7,
        width  = 12,
        height = 6,

        properties = {
          metrics = [
            ["kandidat-23-sentimentapp", "sentiment.detected_companies.gauge"]
          ]
          title = "Detected Companies (Gauge)"
        }
      }
    ]
  })
}

# ================================
# CLOUDWATCH ALARM
# ================================
resource "aws_cloudwatch_metric_alarm" "latency_alarm" {
  alarm_name                = "kandidat23-bedrock-latency-high"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  metric_name               = "bedrock.api.latency"
  namespace                 = "kandidat-23-sentimentapp"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 5000    # 5 sekunder
  alarm_description         = "API latency is above 5 seconds"
  alarm_actions             = [aws_sns_topic.alarm_topic.arn]
}
