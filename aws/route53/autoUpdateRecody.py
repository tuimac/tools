import traceback
import boto3

HOSTED_ZONE_ID = 'xxxxxxxxxxxx'

def updateRecord():
    try:
        route53 = boto3.client('route53')
        route53.change_resource_record_sets(
            HostedZoneId = HOSTED_ZONE_ID,
            ChangeBatch = {
                'Changes': [
                    {
                        'Action': 'UPSERT',
                        'ResourceRecordSet': {
                            'Name': 'home.tuimac.com',
                            'Type': 'A',
                            'TTL': 30,
                            'ResourceRecords': [
                                {'Value': IP}
                            ]
                        }
                    }
                ]
            }
        )
    except Exception as e:
        raise e

def compareResult():
    try:
        # Get MyIP
        myip = ''
        with urllib.request.urlopen('https://api.ipify.org?format=json') as response:
            myip = json.loads(response.read().decode())['ip']

        # Get home.tuimac.com IP address
        route53 = boto3.client('route53')
        homeip = route53.list_resource_record_sets(
            HostedZoneId = HOSTED_ZONE_ID,
            StartRecordName = 'home.tuimac.com'
        )['ResourceRecordSets'][0]['ResourceRecords'][0]['Value']
        if myip == homeip:
            return True
        else:
            global IP
            IP = myip
            return False
    except:
        return True

if __name__ == '__main__':
    try:
        if compareResult() == False:
            updateRecord()
            print('Changed')
        else:
            print('NoChange')
    except:
        traceback.print_exc()
