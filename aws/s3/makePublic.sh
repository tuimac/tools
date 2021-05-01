#!/bin/bash

S3BUCKET='11-test'
FILENAME='policy.json'

disableBlockPublicAccess(){
    aws s3api delete-public-access-block --bucket ${S3BUCKET}
}

function createPolicy(){
    
    cat <<EOF > ${FILENAME}
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
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
    disableBlockPublicAccess
    createPolicy
    putBucketPolicy
    rm ${FILENAME}
}

main
