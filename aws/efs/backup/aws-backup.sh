#!/bin/bash

REGION='ap-northeast-3'
VAULT_NAME='primary'
EFS_ARN='arn:aws:elasticfilesystem:ap-northeast-3:409826931222:file-system'

aws backup create-backup-vault \
    --backup-vault-name ${VAULT_NAME} \
    --region ${REGION}

aws backup start-backup-job \
    --backup-vault-name ${VAULT_NAME} \
    --resource-arn ${EFS_ARN} \
    --iam-role-arn 
