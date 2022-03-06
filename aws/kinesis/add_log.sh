#!/bin/bash

FLUENTD_CONF='/etc/td-agent/td-agent.conf'
NAME='auditd'
LOG_PATH='/var/log/os/audit/audit.log'
FLUENTD_CONF='/etc/td-agent/td-agent.conf'
S3_BUCKET='000-tuimac-dev'
IAM_ROLE='arn:aws:iam::409826931222:role/kinesis-s3'
LOG_NAME_PATTERN=${HOSTNAME}'_'${NAME}

function create_logs(){
    aws logs create-log-group --log-group-name '/aws/firehose/'${LOG_NAME_PATTERN}
    aws logs create-log-stream \
        --log-group-name '/aws/firehose/'${LOG_NAME_PATTERN} \
        --log-stream-name ${LOG_NAME_PATTERN}
}

function create_delivery_stream(){
    aws firehose create-delivery-stream \
        --delivery-stream-name ${LOG_NAME_PATTERN} \
        --delivery-stream-type 'DirectPut' \
        --delivery-stream-encryption-configuration-input 'KeyType=AWS_OWNED_CMK' \
        --s3-destination-configuration '
            {
                "RoleARN": "'${IAM_ROLE}'",
                "BucketARN": "arn:aws:s3:::'${S3_BUCKET}'",
                "Prefix": "log/'${LOG_NAME_PATTERN}'",
                "ErrorOutputPrefix": "error/'${LGO_NAME_PATTERN}'",
                "BufferingHints": {
                    "SizeInMBs": 5,
                    "IntervalInSeconds": 300
                },
                "CompressionFormat": "GZIP",
                "CloudWatchLoggingOptions": {
                    "Enabled": true,
                    "LogGroupName": "/aws/firehose/'${LOG_NAME_PATTERN}'",
                    "LogStreamName": "'${LOG_NAME_PATTERN}'"
                }
            }' \
        --tag '
            [
                {
                    "Key": "Name",
                    "Value": "'${HOSTNAME}'_'${NAME}'"
                }
            ]'
}

function config_fluentd_conf(){
    sudo bash -c "cat <<EOF> $FLUENTD_CONF
<source>
  @type tail
  <parse>
    @type none
  </parse>
  path $LOG_PATH
  pos_file /var/log/td-agent/$NAME.pos
  tag kinesis.$NAME
</source>
<match kinesis.$NAME>
  @type kinesis_firehose
  region ap-northeast-3
  delivery_stream_name $LOG_NAME_PATTERN
</match>
EOF"
    sudo systemctl restart td-agent.service
}

function main(){
    create_logs
    create_delivery_stream
    config_fluentd_conf
}

main
