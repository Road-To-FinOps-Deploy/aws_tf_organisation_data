data "archive_file" "organisation_data_zip" {
  type        = "zip"
  source_file = "${path.module}/source/organisation_data.py"
  output_path = "${path.module}/source/organisation_data.zip"
}

resource "aws_lambda_function" "organisation_data" {
  filename         = "${path.module}/source/organisation_data.zip"
  function_name    = "${var.function_prefix}_organisation_cleanup"
  role             = aws_iam_role.iam_role_for_organisation.arn
  handler          = "organisation_data.lambda_handler"
  source_code_hash = data.archive_file.organisation_data_zip.output_base64sha256
  runtime          = "python3.6"
  memory_size      = "512"
  timeout          = "150"
  environment {
    variables = {
      BUCKET_NAME    = var.bucket_name
      TAGS = var.tags
    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_organisation_data" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.organisation_data.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.organisation_data_cloudwatch_rule.arn
}

resource "aws_cloudwatch_event_rule" "organisation_data_cloudwatch_rule" {
  name                = "organisation_data_lambda_trigger"
  schedule_expression = var.organisation_cleanup_cron
}

resource "aws_cloudwatch_event_target" "organisation_data_lambda" {
  rule      = aws_cloudwatch_event_rule.organisation_data_cloudwatch_rule.name
  target_id = "organisation_data_lambda_target"
  arn       = aws_lambda_function.organisation_data.arn
}

