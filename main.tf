provider "aws" {
  region = "ap-south-1"
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "LambdaExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "LambdaDynamoDBPolicy"
  role   = aws_iam_role.lambda_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:dynamodb:ap-south-1:${data.aws_caller_identity.current.account_id}:table/MarkAverageCalculatorTable"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_dynamodb_table" "mark_average_calculator_table" {
  name           = "MarkAverageCalculatorTable"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "ID"
  attribute {
    name = "ID"
    type = "S"
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_function"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "mark_average_calculator" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "MarkAverageCalculator"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  memory_size      = 128
  timeout          = 10
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.mark_average_calculator_table.name
    }
  }
}

resource "aws_api_gateway_rest_api" "mark_average_calculator_api" {
  name        = "MarkAverageCalculatorAPI"
  description = "API for Mark Average Calculator"
}

resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = aws_api_gateway_rest_api.mark_average_calculator_api.id
  parent_id   = aws_api_gateway_rest_api.mark_average_calculator_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.mark_average_calculator_api.id
  resource_id   = aws_api_gateway_resource.api_resource.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "proxy_integration" {
  rest_api_id = aws_api_gateway_rest_api.mark_average_calculator_api.id
  resource_id = aws_api_gateway_resource.api_resource.id
  http_method = aws_api_gateway_method.proxy_method.http_method
  integration_http_method = "POST"
  type         = "AWS_PROXY"
  uri          = aws_lambda_function.mark_average_calculator.invoke_arn
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mark_average_calculator.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.mark_average_calculator_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_method.proxy_method,
    aws_api_gateway_integration.proxy_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.mark_average_calculator_api.id
  stage_name  = "dev"
}

data "aws_caller_identity" "current" {}
