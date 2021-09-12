#!/usr/bin/env python3

import boto3
import urllib.request
import json
import sys
import traceback

# You need to change these parameters
TOKEN = ''
BASE_URL = 'https://tuimac.awsapps.com'
FOLDER_NAME = 'python'

# Don't change these parameters
REGION = 'ap-northeast-1'
ZOCALO_FQDN = 'zocalo.' + REGION + '.amazonaws.com'
TARGET_URL = 'https://' + ZOCALO_FQDN + '/gb/api/v1/document/'
DOCUMENT_ID_LIST = []

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
        request = urllib.request.Request(url, json.dumps(payload).encode(), header, method='PUT')
        with urllib.request.urlopen(request) as response:
            response.read().decode()
        print('Disabling download permisson was successed for ' + document_id)
    except:
        print('Get some error for ' + document_id, file=sys.stderr)
        raise

# Get all document ID and return the list
def get_document_id(workdocs, folder_id):
    document_id_list = []
    contents = workdocs.describe_folder_contents(
        AuthenticationToken = TOKEN,
        FolderId = folder_id
    )
    for document in contents['Documents']:
        document_id_list.append(document['Id'])
    try:
        for folder in contents['Folders']:
            for return_id in get_document_id(workdocs, folder['Id']):
                document_id_list.append(return_id)
        return document_id_list
    except KeyError:
        return document_id_list

# Main
if __name__ == '__main__':
    try:
        workdocs = boto3.client('workdocs')
        
        # Get the target folderID
        root_folders = workdocs.describe_root_folders(AuthenticationToken=TOKEN)['Folders']
        root_folder_id = [folder['Id'] for folder in root_folders if folder['Name'] != 'recycle-bin'][0]
        folders = workdocs.describe_folder_contents(
            AuthenticationToken = TOKEN,
            FolderId = root_folder_id
        )['Folders']
        target_folder_id = [folder['Id'] for folder in folders if folder['Name'] == FOLDER_NAME][0]

        # Get all documentID under the target folderID
        document_id_list = get_document_id(workdocs, target_folder_id)

        # Disable a download permission for all target documents
        for document_id in document_id_list:
            disable_download_permission(document_id)
    except:
        traceback.print_exc()
