import json
import boto3
import time
import datetime
import os

def describe_old_client_vpn(ec2):
    result = dict()
    result['id'] = ec2.describe_client_vpn_endpoints(
        Filters = [
            {
                'Name': 'tag:Type',
                'Values': ['Auto']
            }    
        ]
    )['ClientVpnEndpoints'][0]['ClientVpnEndpointId']
    result['associated_id'] = ec2.describe_client_vpn_target_networks(
        ClientVpnEndpointId = result['id']
    )['ClientVpnTargetNetworks'][0]['AssociationId']
    
    return result

def create_client_vpn(ec2):
    vpn_info = ec2.create_client_vpn_endpoint(
        ClientCidrBlock = os.environ['CIDR'],
        ServerCertificateArn = os.environ['SERVER_CERT_ARN'],
        AuthenticationOptions = [
            {
                'Type': 'certificate-authentication',
                'MutualAuthentication': {
                    'ClientRootCertificateChainArn': os.environ['CLIENT_CERT_ARN']
                }
            }
        ],
        ConnectionLogOptions = {
            'Enabled': True,
            'CloudwatchLogGroup': os.environ['LOGS_GROUP'],
            'CloudwatchLogStream': os.environ['LOGS_STREAM']
        },
        DnsServers = ['8.8.8.8'],
        TransportProtocol = 'tcp',
        VpnPort = 443,
        SplitTunnel = True,
        SecurityGroupIds = os.environ['SECURITY_GROUP_IDS'].split(','),
        VpcId = os.environ['VPC_ID'],
        SelfServicePortal = 'enabled',
        TagSpecifications = [
            {
                'ResourceType': 'client-vpn-endpoint',
                'Tags': [
                    {
                        'Key': 'Name',
                        'Value': os.environ['VPN_NAME'] + '_' + datetime.datetime.today().strftime('%Y%m%d')
                    },
                    {
                        'Key': 'Type',
                        'Value': 'Auto'
                    }
                ]
            }    
        ]
    )
    time.sleep(3)
    ec2.associate_client_vpn_target_network(
        ClientVpnEndpointId = vpn_info['ClientVpnEndpointId'],
        SubnetId = os.environ['TARGET_SUBNET_ID']
    )
    time.sleep(3)
    
    for cidr in os.environ['AUTH_INGRESSES'].split(','):
        ec2.authorize_client_vpn_ingress(
            ClientVpnEndpointId = vpn_info['ClientVpnEndpointId'],
            TargetNetworkCidr = cidr,
            AuthorizeAllGroups = True
        )

    #while True:
    #    status = ec2.describe_client_vpn_endpoints(ClientVpnEndpointIds = [vpn_info['ClientVpnEndpointId']])['ClientVpnEndpoints'][0]['Status']['Code']
    #    if status == 'available':
    #        break
    #    time.sleep(3)
    
    return os.environ['ENV'] + '.' + vpn_info['DnsName']

def delete_old_client_vpn(ec2, old_client_vpn_info):
    ec2.disassociate_client_vpn_target_network(
        ClientVpnEndpointId = old_client_vpn_info['id'],
        AssociationId = old_client_vpn_info['associated_id']
    )
    time.sleep(3)
    ec2.delete_client_vpn_endpoint(
        ClientVpnEndpointId = old_client_vpn_info['id']
    )

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')

    fqdn = create_client_vpn(ec2)
    #update_vpn_dns(route53, fqdn)
    #delete_old_client_vpn(ec2, old_client_vpn_info)
    
