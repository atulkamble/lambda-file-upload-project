#!/bin/bash
zip function.zip lambda_function.py

# Create IAM Role
aws iam create-role \
  --role-name lambda-basic-role \
  --assume-role-policy-document file://trust-policy.json

# Attach Policy to Role
aws iam put-role-policy \
  --role-name lambda-basic-role \
  --policy-name lambda-basic-logs \
  --policy-document file://role-policy.json

# Wait a few seconds for IAM role to be ready
sleep 10

# Zip the Lambda function code
zip function.zip lambda_function.py

# Create the Lambda function
aws lambda create-function \
  --function-name uploadHandler \
  --runtime python3.12 \
  --role arn:aws:iam::535002879962:role/lambda-basic-role \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://function.zip
  --region us-east-1
  --timeout 15
  --memory-size 512
  
