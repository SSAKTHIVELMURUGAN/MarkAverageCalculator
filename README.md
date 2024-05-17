# MarkAverageCalculator

This project provides a web-based Mark Average Calculator that calculates the total, average, and percentage of marks for a given number of subjects. The results are stored in an AWS DynamoDB table via a Lambda function, which is exposed through an API Gateway.

## Features

- Web-based input form for entering marks.
- Calculation of total marks, average, and percentage.
- Storage of calculated results in AWS DynamoDB.
- API Gateway endpoint to interact with the Lambda function.

## Prerequisites

- AWS Account
- AWS CLI installed and configured

## AWS Features Used

### 1. AWS Lambda
AWS Lambda is used to run the backend code that processes the input marks, calculates the total, average, and percentage, and stores the results in DynamoDB.

- **Feature**: Serverless compute service.
- **Usage**: Runs the `lambda_function.py` code in response to API Gateway requests.

### 2. Amazon API Gateway
Amazon API Gateway is used to create, publish, maintain, monitor, and secure APIs.

- **Feature**: Fully managed service for creating and publishing APIs.
- **Usage**: Exposes the Lambda function through a RESTful API endpoint.

### 3. Amazon DynamoDB
Amazon DynamoDB is a fast and flexible NoSQL database service for any scale.

- **Feature**: Fully managed NoSQL database service.
- **Usage**: Stores the calculated results (total, average, and percentage) of the marks.

### 4. AWS Identity and Access Management (IAM)
IAM is used to manage access to AWS services and resources securely.

- **Feature**: Access control and identity management.
- **Usage**: Manages roles and permissions for Lambda to interact with DynamoDB and create CloudWatch logs.

### 5. Amazon CloudWatch
Amazon CloudWatch is used for monitoring and logging.

- **Feature**: Monitoring and observability service.
- **Usage**: Logs the execution details of the Lambda function.

