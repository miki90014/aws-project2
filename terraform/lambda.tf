resource "aws_sqs_queue" "message_queue" {
  name                      = "message-queue"
  delay_seconds            = 0
  message_retention_seconds = 86400
}

resource "aws_lambda_function" "message_processor" {
  filename         = "function.zip"
  function_name    = "message_processor"
  role             = "arn:aws:iam::919571953845:role/LabRole"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.10"
  timeout          = 10
  memory_size      = 128
  publish = true

  environment {
    variables = {
      QUEUE_URL = aws_sqs_queue.message_queue.id
    }
  }
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.message_queue.arn
  function_name    = aws_lambda_function.message_processor.arn
  batch_size       = 1
  enabled          = true
}

resource "aws_lambda_function_event_invoke_config" "lambda_config" {
  function_name = aws_lambda_function.message_processor.function_name

  maximum_retry_attempts   = 2
  maximum_event_age_in_seconds = 60
}

/*resource "aws_lambda_provisioned_concurrency_config" "concurrency" {
  function_name          = aws_lambda_function.message_processor.function_name
  qualifier              = 7
  provisioned_concurrent_executions = 2
}*/

resource "aws_cloudwatch_metric_alarm" "sqs_messages_waiting" {
  alarm_name                = "SQSMessageQueueAlarm"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  period                    = 60
  metric_name               = "NumberOfMessagesSent"
  namespace                 = "AWS/SQS"
  statistic                 = "Average"
  threshold                 = 3
  alarm_description         = "Alarm when SQS message count exceeds 3"
  actions_enabled           = true

  dimensions = {
    QueueName = aws_sqs_queue.message_queue.name
  }
}

resource "aws_sns_topic" "alarm_topic" {
  name = "AlarmTopic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "email"
  endpoint  = "tinusia09@gmail.com"
}
