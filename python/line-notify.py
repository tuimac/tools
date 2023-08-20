import os
import urllib.request
import urllib.parse
import traceback

def send_notify(message):
    token = os.environ['TOKEN']
    url = os.environ['URL']
    headers = { 'Authorization': f'Bearer { token }', 'Content-Type': 'application/x-www-form-urlencoded' }
    payload = { 'message': f'message: { message }' }
    
    request = urllib.request.Request(url, urllib.parse.urlencode(payload).encode('utf-8'), headers, method='POST')
    with urllib.request.urlopen(request) as response:
        pass

def lambda_handler(event, context):
    try:
        send_notify(str(event['Records'][0]['Sns']['Message']))
    except:
        send_notify(str(traceback.format_exc()))
