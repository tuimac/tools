#!/bin/bash

sleep $BACKUP_INTERVAL 
if [[ $INIT_RESTORE == 'yes' ]]; then
    aws s3 cp ${BACKUP_S3_FILE_PATH} ${BACKUP_FILE_NAME}
    mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -h ${MYSQL_HOSTNAME} < ${BACKUP_FILE_NAME}
fi

while true; do
    mysqldump -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -h ${MYSQL_HOSTNAME} --databases ${MYSQL_DATABASE} > ${BACKUP_FILE_NAME}
    aws s3 cp ${BACKUP_FILE_NAME} ${BACKUP_S3_FILE_PATH}
    sleep $BACKUP_INTERVAL
done
