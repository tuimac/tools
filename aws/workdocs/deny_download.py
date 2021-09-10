#!/usr/bin/env python3

import boto3
import urllib.request
import json
import sys
import traceback

# You need to change these parameters
TOKEN = ''
BASE_URL = 'https://xxxxxx.awsapps.com'

# Don't change these parameters
ZOCALO_FQDN = 'zocalo.ap-northeast-1.amazonaws.com'
TARGET_URL = 'https://' + ZOCALO_FQDN + '/gb/api/v1/document/'
DOCUMENT_ID

# Disable download permission for a sigle document
def disable_download_permission(document_id):
    try:
        url = TARGET_URL + document_id
        header = {
            'Accept': 'application/json, text/plain, */*',
            'Accept-Encoding': 'gzip, deflate, br',
            'Accept-Language': 'en-US,en;q=0.9',
            'Cache-Control': 'no-cache',
            'Content-Type': 'application/json;charset=UTF-8',
        }
        header['Host'] = ZOCALO_FQDN
        header['Origin'] = BASE_URL
        header['Referer'] = BASE_URL + '/'
        header['Authentication'] = TOKEN
        payload = {
            'DocumentLevelPermissions': {
                'Download': 'REVOKE',
                'Upload': 'REVOKE'
            }
        }
        payload['DocumentId'] = document_id
        req = urllib.request.Request(url, json.dumps(payload).encode(), header, method='PUT')
        with urllib.request.urlopen(req) as res:
            print(res.read().decode())
        print('Disabling download permisson was successed for ' + document_id)
    except:
        print('Get some error for ' + document_id, file=sys.stderr)
        raise

# Get all document ID and return the list
def get_document_id(workdocs):


# Main
if __name__ == '__main__':
    try:
        workdocs = boto3.client('workdocs')
        document_id_list = get_document_id(workdocs)
        #for document_id in document_id_list:
        #    disable_download_permission(document_id)
    except:
        traceback.print_exc()
