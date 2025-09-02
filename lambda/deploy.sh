#!/usr/bin/env bash
set -euo pipefail

# ----- Pre-requisites -----
# Detect Amazon Linux version and install zip if missing
if ! command -v zip >/dev/null 2>&1; then
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$VERSION_ID" in
      2) sudo yum install -y zip ;;     # Amazon Linux 2
      2023) sudo dnf install -y zip ;;  # Amazon Linux 2023
      *) echo "Unknown Amazon Linux version: $VERSION_ID" && exit 1 ;;
    esac
  fi
fi

# ----- Config -----
REGION="${REGION:-us-east-1}"
FUNCTION_NAME="${FUNCTION_NAME:-uploadHandler}"
ROLE_NAME="${ROLE_NAME:-lambda-basic-role}"
RUNTIME="${RUNTIME:-python3.12}"
HANDLER="${HANDLER:-lambda_function.lambda_handler}"
ZIP_FILE="function.zip"

echo "Packaging Lambda..."
zip -q -r "${ZIP_FILE}" lambda_function.py

# ----- Create or ensure IAM role exists -----
if ! aws iam get-role --role-name "${ROLE_NAME}" >/dev/null 2>&1; then
  echo "Creating IAM role ${ROLE_NAME}..."
  aws iam create-role \
    --role-name "${ROLE_NAME}" \
    --assume-role-policy-document '{
      "Version": "2012-10-17",
      "Statement": [{
        "Effect": "Allow",
        "Principal": {"Service": "lambda.amazonaws.com"},
        "Action": "sts:AssumeRole"
      }]
    }' >/dev/null

  # Attach basic logging permissions
  aws iam attach-role-policy \
    --role-name "${ROLE_NAME}" \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

  echo "Waiting for IAM role to propagate..."
  sleep 12
else
  echo "IAM role ${ROLE_NAME} already exists."
fi

ROLE_ARN="$(aws iam get-role --role-name "${ROLE_NAME}" --query 'Role.Arn' --output text)"
echo "Using role ARN: ${ROLE_ARN}"

# ----- Create or update function -----
if ! aws lambda get-function --function-name "${FUNCTION_NAME}" --region "${REGION}" >/dev/null 2>&1; then
  echo "Creating Lambda function ${FUNCTION_NAME} in ${REGION}..."
  aws lambda create-function \
    --function-name "${FUNCTION_NAME}" \
    --runtime "${RUNTIME}" \
    --role "${ROLE_ARN}" \
    --handler "${HANDLER}" \
    --zip-file "fileb://${ZIP_FILE}" \
    --timeout 15 \
    --memory-size 512 \
    --region "${REGION}" >/dev/null
  echo "Created."
else
  echo "Function exists. Updating code..."
  aws lambda update-function-code \
    --function-name "${FUNCTION_NAME}" \
    --zip-file "fileb://${ZIP_FILE}" \
    --region "${REGION}" >/dev/null
  echo "Updated code."
fi

echo "✅ Done."
echo "Test with:"
echo "aws lambda invoke --function-name ${FUNCTION_NAME} --region ${REGION} out.json && cat out.json && echo"
