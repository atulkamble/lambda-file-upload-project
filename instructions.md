To **run this project on macOS**, follow these detailed steps to ensure everything works correctly from your Mac terminal. This assumes you have a valid AWS account and permissions.

---

## ✅ Prerequisites on Mac

Before running the project:

### 1. ✅ Install and Configure AWS CLI

```bash
brew install awscli
aws configure
```

Enter your:

* Access Key
* Secret Key
* Default Region (e.g. `us-east-1`)
* Output format (e.g. `json`)

---

### 2. ✅ Install Python and Zip (if not already)

```bash
brew install python
brew install zip
```

---

## 🚀 Running the Project on Mac

### 🪪 Replace Placeholders

Update the following placeholders in your `.sh` scripts:

* Replace `YOUR_ACCOUNT_ID` with your actual AWS account ID.
* Replace `LambdaExecutionRole` with the actual IAM role name (or create it, shown below).

---

### 🧠 Step-by-Step Execution

#### ✅ Step 1: Prepare Project Structure

If not already done:

```bash
mkdir -p lambda-ui-project/{lambda,api,ui}
cd lambda-ui-project
```

Create the necessary files and copy the code you’ve provided into them:

* `lambda/lambda_function.py`
* `lambda/deploy_lambda.sh`
* `api/create_api_gateway.sh`
* `ui/index.html`
* `ui/bucket-policy.json`
* `ui/deploy_ui.sh`

Ensure all `.sh` files are executable and in Unix format:

```bash
find . -name "*.sh" -exec dos2unix {} \;  # Or use `sed` if no dos2unix
chmod +x lambda/deploy_lambda.sh api/create_api_gateway.sh ui/deploy_ui.sh
```

---

#### ✅ Step 2: Create IAM Role (One-Time Setup)

If the role doesn’t exist, create it:

Create `trust-policy.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

Then:

```bash
aws iam create-role \
  --role-name LambdaExecutionRole \
  --assume-role-policy-document file://trust-policy.json

aws iam attach-role-policy \
  --role-name LambdaExecutionRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
```

Get your account ID with:

```bash
aws sts get-caller-identity --query "Account" --output text
```

---

#### ✅ Step 3: Deploy the Lambda Function

```bash
cd lambda
bash deploy_lambda.sh
```

---

#### ✅ Step 4: Set Up API Gateway

```bash
cd ../api
bash create_api_gateway.sh
```

Copy the **Invoke URL** printed in the terminal and update it in `ui/index.html`:

```js
const res = await fetch("https://<your-api-id>.execute-api.us-east-1.amazonaws.com/", {
```

---

#### ✅ Step 5: Deploy Web UI to S3

```bash
cd ../ui
bash deploy_ui.sh
```

Visit the URL printed in the terminal, such as:

```
http://lambda-ui-frontend-atul.s3-website-us-east-1.amazonaws.com
```

You’ll see your file upload form ready!

---

## 🧪 Test the App

1. Open the S3 website URL in your browser.
2. Upload a small text file or image.
3. It will call the Lambda via API Gateway and display the response.

---

Would you like a shell script to **automate all these steps in one go**, or a **ZIP of the ready-to-run project**?
