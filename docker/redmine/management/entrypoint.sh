#!/bin/bash

BACKUP_FILE='redmine-backup.sql'
S3_BUCKET='tuimac-redmine'

while true; do
    mysqldump -u ${REDMINE_DB_USERNAME} -p${REDMINE_DB_PASSWORD} --databases redmine > ${BACKUP_FILE}
    aws s3 cp ${BACKUP_FILE} s3://${S3_BUCKET}/backup/${BACKUP_FILE}
    sleep 60
done
