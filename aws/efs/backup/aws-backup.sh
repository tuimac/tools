#!/bin/bash

REGION='ap-northeast-3'
VAULT_NAME='primary'
EFS_ARN=''
BACKUP_ROLE=''

aws backup create-backup-vault \
    --backup-vault-name ${VAULT_NAME} \
    --region ${REGION}

aws backup start-backup-job \
    --backup-vault-name ${VAULT_NAME} \
    --resource-arn ${EFS_ARN} \
    --iam-role-arn ${BACKUP_ROLE} \
    --start-window-minutes 60 \
    --complete-window-minutes 10080 \
    --lifecycle DeleteAfterDays=1 \
    --region ${REGION}
