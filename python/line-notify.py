#!/usr/bin/env python3

import requests

TOKEN = ''
URL = 'https://notify-api.line.me/api/notify'

def send_notify(message):
    requests.post(
        URL,
        headers = {
            'Authorization': f'Bearer {TOKEN}'
        },
        data = {
            'message': f'message: {message}'
        }
    )

if __name__ == '__main__':
    message = 'test'
    send_notify(message)