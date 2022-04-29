#!/bin/bash

RECOVERY_ARN=''
BACKUP_ROLE=''
FILESYS_ID=''
REGION='ap-northeast-3'

aws backup start-restore-job \
    --recovery-point-arn ${RECOVERY_ARN} \
    --iam-role-arn ${BACKUP_ROLE} \
    --region ${REGION} \
    --metadata '{
        "file-system-id": "'${FILESYS_ID}'",
        "Encrypted": "true",
        "PerformanceMode": "generalPurpose",
        "newFileSystem": "false"
    }'
