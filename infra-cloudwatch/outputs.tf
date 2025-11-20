output "sns_topic_arn" {
  value = aws_sns_topic.alarm_topic.arn
}

output "dashboard_name" {
  value = aws_cloudwatch_dashboard.sentiment_dashboard.dashboard_name
}

output "alarm_name" {
  value = aws_cloudwatch_metric_alarm.latency_alarm.alarm_name
}
