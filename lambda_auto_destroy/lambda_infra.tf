resource "aws_iam_role" "lambda_exec" {
  name = "lambda-auto-destroy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "auto_destroy" {
  filename      = "lambda_function_payload.zip"
  function_name = "auto-destroy-inactivity"
  role          = module.iam.lambda_role_arn
  handler       = "lambda_check_inactivity.lambda_handler"
  runtime       = "python3.10"
  timeout       = 300

  environment {
    variables = {
      LOAD_BALANCER_NAME = module.alb.alb_full_name
    }
  }

  depends_on = [module.iam]
}

resource "aws_cloudwatch_event_rule" "every_hour" {
  schedule_expression = "rate(1 hour)"
}

resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule      = aws_cloudwatch_event_rule.every_hour.name
  target_id = "LambdaAutoDestroy"
  arn       = aws_lambda_function.auto_destroy.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auto_destroy.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_hour.arn
}