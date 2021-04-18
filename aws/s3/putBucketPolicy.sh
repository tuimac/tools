#!/bin/bash

S3BUCKET='123-testtest'
FILENAME='policy.json'

function createPolicy(){
    
    cat <<EOF > ${FILENAME}
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "apigateway.amazonaws.com"
            },
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": "arn:aws:s3:::${S3BUCKET}/*"
        }
    ]
}
EOF
}

function putBucketPolicy(){
    aws s3api put-bucket-policy \
        --bucket ${S3BUCKET} \
        --policy file://${FILENAME}
}

function main(){
    createPolicy
    putBucketPolicy
    rm ${FILENAME}
}

main
