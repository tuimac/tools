#!/usr/bin/env python3

import boto3

if __name__ == "__main__":
    logs = boto3.client("logs")
    logGroups = logs.describe_log_groups()
    for logGroup in logGroups["logGroups"]:
        logs.delete_log_group(logGroupName=logGroup["logGroupName"])
