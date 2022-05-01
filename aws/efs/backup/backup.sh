#!/bin/bash

REGION='ap-northeast-3'
VAULT_NAME='efs-test'

function backup(){
    aws backup start-backup-job \
        --backup-vault-name ${VAULT_NAME} \
        --resource-arn ${EFS_ARN} \
        --iam-role-arn ${BACKUP_ROLE_ARN} \
        --start-window-minutes 60 \
        --complete-window-minutes 10080 \
        --lifecycle DeleteAfterDays=1 \
        --region ${REGION}
}

function restore(){
    aws backup start-restore-job \
        --recovery-point-arn ${RECOVERY_ARN} \
        --iam-role-arn ${BACKUP_ROLE_ARN} \
        --region ${REGION} \
        --metadata '{
            "file-system-id": "'${FILESYS_ID}'",
            "Encrypted": "true",
            "PerformanceMode": "generalPurpose",
            "newFileSystem": "false"
        }'
}

function backup_list(){
    aws backup describe-backup-vault \
        --backup-vault-name ${VAULT_NAME} \
        --region ${REGION}
}

function userguide(){
    echo -e "usage: ./backup.sh [backup | restore | ...]"
    echo -e "
optional arguments:

backup                  Take the backup of EFS FileSystem
restore                 Restore EFS backup files to target filesystem.
help                    Show the easy guide of the utility tool.
    "
}

function main(){
    [[ -z $1 ]] && { userguide; exit 1; }
    case $1 in
        'backup')
            backup;;
        'restore')
            restore;;
        'list')
            backup_list;;
        'help')
            userguide;;
        *)
            userguide
            exit 1;;
    esac 
}

main $1
