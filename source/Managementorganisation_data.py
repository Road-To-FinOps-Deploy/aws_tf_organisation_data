#!/usr/bin/env python3
#Gets org data, grouped by ous and tags from managment accounts in json
#Author Stephanie Gooch 2020
import argparse
import boto3
from botocore.exceptions import ClientError
from botocore.client import Config
import os
import datetime
import json

def myconverter(o):
    if isinstance(o, datetime.datetime):
        return o.__str__()

def list_tags(client, resource_id):
    tags = []
    paginator = client.get_paginator("list_tags_for_resource")
    response_iterator = paginator.paginate(ResourceId=resource_id)
    for response in response_iterator:
        tags.extend(response['Tags'])
    return tags
    
def lambda_handler(event, context):

    client = boto3.client(
        "organizations", region_name="us-east-1") #Using the Organizations client to get the data. This MUST be us-east-1 regardless of region you have the Lamda in

    root_id    = client.list_roots()['Roots'][0]['Id']
    ou_id_list = get_ou_ids(root_id, client)
    
    with open('/tmp/ou-org.json', 'w') as f:
        for ou in ou_id_list.keys():
            account_data(f, ou, ou_id_list[ou][0], client)
    s3_upload('ou-org')

    with open('/tmp/acc-org.json', 'w') as f:
        account_data(f, root_id, root_id, client)
    s3_upload('acc-org')

def account_data(f, parent, parent_name, client):
    tags_check = os.environ["TAGS"]
    account_id_list = get_acc_ids(parent, client)
    for account_id in account_id_list:
        response = client.describe_account(AccountId=account_id)
        account  = response["Account"]          
        if tags_check != '':
            tags_list = list_tags(client, account["Id"])
            for tag in os.environ.get("TAGS").split(","):
                for org_tag in tags_list:
                    if tag == org_tag['Key']: 
                        value = org_tag['Value']
                        kv = {tag : value}
                        account.update(kv)
        account.update({'Parent' : parent_name})        
        data = json.dumps(account, default = myconverter) 

        f.write(data)
        f.write('\n')

def s3_upload(file_name):
    bucket = os.environ["BUCKET_NAME"] 
    try:
        s3 = boto3.client('s3', os.environ["REGION"],config=Config(s3={'addressing_style': 'path'}))
        s3.upload_file(f'/tmp/{file_name}.json', bucket, f"organisation-data/{file_name}.json") 
        print(f"{file_name}org data in s3")
    except Exception as e:
        print(e)

def get_ou_ids(parent_id, client):
    full_result = {}
    paginator = client.get_paginator('list_organizational_units_for_parent')
    iterator  = paginator.paginate( ParentId=parent_id)
    for page in iterator:
        for ou in page['OrganizationalUnits']:
            print(ou['Name'])
            full_result[ou['Id']]=[]
            full_result[ou['Id']].append(ou['Name'])
    return full_result

def get_acc_ids(parent_id,  client):
    full_result = []
    paginator = client.get_paginator('list_accounts_for_parent')
    iterator  = paginator.paginate(ParentId=parent_id)
    for page in iterator:
        for acc in page['Accounts']:
            print(acc['Id'])
            full_result.append(acc['Id'])
    return full_result