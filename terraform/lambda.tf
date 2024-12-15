resource "aws_sqs_queue" "message_queue" {
  name                      = "message-queue"
  delay_seconds            = 0
  message_retention_seconds = 86400
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda-execution-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "lambda_policy_attach" {
  name       = "lambda-policy-attach"
  roles      = [aws_iam_role.lambda_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "message_processor" {
  filename         = "function.zip"
  function_name    = "message_processor"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  timeout          = 10
  memory_size      = 128

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

resource "aws_lambda_provisioned_concurrency_config" "concurrency" {
  function_name          = aws_lambda_function.message_processor.function_name
  qualifier              = "$LATEST"
  provisioned_concurrent_executions = 2
}
