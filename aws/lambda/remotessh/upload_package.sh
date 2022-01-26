#!/bin/bash

cp ~/tuimac.pem .
pip3 install paramiko -t .
zip -r deploy.zip .
aws lambda update-function-code --function-name remotessh --zip-file fileb://deploy.zip
