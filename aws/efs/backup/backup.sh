#!/bin/bash

REGION='ap-northeast-3'
VAULT_NAME='efs-test'
FILESYSTEM_ID='fs-03a8fc2a282ec858f'

function backup(){
    aws backup start-backup-job \
        --backup-vault-name ${VAULT_NAME} \
        --resource-arn ${EFS_ARN} \
        --iam-role-arn ${BACKUP_ROLE_ARN} \
        --region ${REGION}
}

function restore(){
    aws backup start-restore-job \
        --recovery-point-arn ${RECOVERY_ARN} \
        --iam-role-arn ${BACKUP_ROLE_ARN} \
        --region ${REGION} \
        --metadata '{
            "file-system-id": "'${FILESYSTEM_ID}'",
            "Encrypted": "true",
            "PerformanceMode": "generalPurpose",
            "newFileSystem": "false"
        }'
}

function backup_list(){
    aws backup list-recovery-points-by-backup-vault \
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
