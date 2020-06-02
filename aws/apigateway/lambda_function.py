import json

def headers(data):
    data["Content-Type"] = "application/json"
    data["Access-Control-Allow-Origin"] = "*"
    data["Access-Control-Allow-Methods"] ="POST, OPTIONS"
    data["Access-Control-Allow-Headers"] = "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token"
    return json.dumps(data)

def body(data, greeting):
    data["message"] = "hello world"
    data["greeting"] = greeting
    return json.dumps(data)

def lambda_handler(event, context):
    data = dict()
    data["headers"] = headers(dict())
    data["body"] = body(dict(), event["greeting"])
    data["statusCode"] = 200
    return data
