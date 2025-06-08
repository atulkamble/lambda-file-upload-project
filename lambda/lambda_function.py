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
