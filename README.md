# Lambda File Upload System with Web UI

This project demonstrates how to upload files via a web interface directly to an AWS Lambda function using API Gateway. The web UI is hosted on S3 as a static website.

## 🌟 Features

- HTML-based upload UI
- API Gateway to trigger Lambda
- Lambda function decodes and handles file data
- UI hosted via S3 static site

## 🔧 Tech Stack

- AWS Lambda (Python)
- Amazon API Gateway
- Amazon S3 (Static Website Hosting)
- HTML + JavaScript Frontend

## 🚀 Quick Start

1. Deploy the Lambda function.
2. Create and configure API Gateway.
3. Upload and host the HTML UI on S3.

Here's a **complete working AWS Lambda + UI project**, including all **code files and deployment steps**. This project lets users upload a file via a web interface, sends it to a Lambda function via API Gateway, and displays a response.

---

## ✅ Project Title: **File Upload to AWS Lambda via Web UI**

---

## 📁 Project Structure

```
lambda-ui-project/
├── lambda/
│   ├── lambda_function.py
│   └── deploy_lambda.sh
│
├── ui/
│   ├── index.html
│   ├── bucket-policy.json
│   └── deploy_ui.sh
│
└── api/
    └── create_api_gateway.sh
```

---

## 🧠 Step 1: Lambda Function

### `lambda/lambda_function.py`

```python
import json
import base64

def lambda_handler(event, context):
    try:
        file_data = base64.b64decode(event['body'])
        file_size = len(file_data)
        return {
            "statusCode": 200,
            "headers": { "Content-Type": "application/json" },
            "body": json.dumps({ "message": f"File received successfully! Size: {file_size} bytes" })
        }
    except Exception as e:
        return {
            "statusCode": 400,
            "body": json.dumps({ "error": str(e) })
        }
```

---

## 🔧 Step 2: Deploy Lambda Function

### `lambda/deploy_lambda.sh`

```bash
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
```

---

## 🌐 Step 3: Create API Gateway

### `api/create_api_gateway.sh`

```bash
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
```

---

## 🌍 Step 4: Web UI

### `ui/index.html`

```html
<!DOCTYPE html>
<html>
<head>
  <title>Lambda File Upload</title>
</head>
<body>
  <h2>Upload File to Lambda</h2>
  <input type="file" id="fileInput" />
  <button onclick="uploadFile()">Upload</button>
  <p id="response"></p>

  <script>
    async function uploadFile() {
      const fileInput = document.getElementById("fileInput");
      const file = fileInput.files[0];
      if (!file) return alert("Please select a file.");

      const arrayBuffer = await file.arrayBuffer();
      const base64Data = btoa(String.fromCharCode(...new Uint8Array(arrayBuffer)));

      const res = await fetch("https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/", {
        method: "POST",
        headers: { "Content-Type": "application/octet-stream" },
        body: base64Data,
      });

      const data = await res.json();
      document.getElementById("response").innerText = data.message || data.error;
    }
  </script>
</body>
</html>
```

> Replace `YOUR_API_ID` with the actual API Gateway ID printed from the script.

---

### `ui/bucket-policy.json`

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::lambda-ui-frontend-atul/*"
    }
  ]
}
```

---

### `ui/deploy_ui.sh`

```bash
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
```

---

## ✅ Final Output:

* Lambda function processes uploaded file
* API Gateway exposes an HTTP endpoint
* HTML frontend allows file upload from browser
* Static site hosted on S3

---

Would you like a ZIP file of this project or a GitHub-ready structure?

