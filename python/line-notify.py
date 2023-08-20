#!/usr/bin/env python3

import urllib.request
import urllib.parse

TOKEN = ''
URL = 'https://notify-api.line.me/api/notify'

def send_notify(message):
    headers = { 'Authorization': f'Bearer {TOKEN}', 'Content-Type': 'application/x-www-form-urlencoded' }
    payload = { 'message': f'message: {message}' }

    request = urllib.request.Request(URL, urllib.parse.urlencode(payload).encode('utf-8'), headers, method='POST')
    with urllib.request.urlopen(request) as response:
        pass

if __name__ == '__main__':
    message = 'test'
    send_notify(message)