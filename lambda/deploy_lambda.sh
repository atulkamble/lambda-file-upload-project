#!/bin/bash

cd lambda
zip function.zip lambda_function.py

aws lambda create-function \
  --function-name uploadHandler \
  --runtime python3.12 \
  --role arn:aws:iam::YOUR_ACCOUNT_ID:role/LambdaExecutionRole \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://function.zip \
  --region us-east-1
