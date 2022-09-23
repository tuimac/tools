#!/bin/bash

CODE_FILE_NAME='lambda_function.py'
FUNCTION_NAME='update_route53'

zip -r ${FUNCTION_NAME}.zip ${CODE_FILE_NAME}
aws lambda update-function-code \
    --function-name ${FUNCTION_NAME} \
    --zip-file fileb://${FUNCTION_NAME}.zip \
    --publish
rm -f ${FUNCTION_NAME}.zip
