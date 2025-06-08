#!/bin/bash

BUCKET_NAME="lambda-ui-frontend-atul"

aws s3api create-bucket \
  --bucket $BUCKET_NAME \
  --region us-east-1

aws s3 website s3://$BUCKET_NAME/ \
  --index-document index.html

aws s3api put-bucket-policy \
  --bucket $BUCKET_NAME \
  --policy file://ui/bucket-policy.json

aws s3 cp ui/index.html s3://$BUCKET_NAME/index.html

echo "Website URL: http://$BUCKET_NAME.s3-website-us-east-1.amazonaws.com"
