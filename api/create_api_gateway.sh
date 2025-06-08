#!/bin/bash

API_ID=$(aws apigatewayv2 create-api \
  --name FileUploadAPI \
  --protocol-type HTTP \
  --target arn:aws:lambda:us-east-1:YOUR_ACCOUNT_ID:function:uploadHandler \
  --region us-east-1 \
  --query 'ApiId' --output text)

echo "API Gateway created with ID: $API_ID"

aws lambda add-permission \
  --function-name uploadHandler \
  --statement-id apigateway-test-2 \
  --action lambda:InvokeFunction \
  --principal apigateway.amazonaws.com \
  --source-arn "arn:aws:execute-api:us-east-1:YOUR_ACCOUNT_ID:$API_ID/*/*/" \
  --region us-east-1

echo "Invoke URL: https://$API_ID.execute-api.us-east-1.amazonaws.com/"
