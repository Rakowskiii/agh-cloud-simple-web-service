import boto3
import json
import os
import secrets
import string


def generate_random_password(length=16):
    alphabet = string.ascii_letters + string.digits + string.punctuation
    password = ''.join(secrets.choice(alphabet) for i in range(length))
    return password


def lambda_handler(event, context):
    secretsmanager_client = boto3.client('secretsmanager')
    rds_client = boto3.client('rds')

    secret_arn = os.environ['SECRET_ARN']
    instance_id = os.environ['INSTANCE_ID']

    current_secret_value = secretsmanager_client.get_secret_value(
        SecretId=secret_arn
    )

    new_password = generate_random_password()

    current = json.loads(current_secret_value['SecretString'])
    try:
        rds_client.modify_db_instance(
            DBInstanceIdentifier=instance_id,
            MasterUserPassword=new_password
        )
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error rotating secret and password: {e}')
        }
    try: 
        secretsmanager_client.put_secret_value(
            SecretId=secret_arn,
            SecretString=json.dumps({
                "host": current['host'],
                "username": current['username'],
                "password": new_password
            })
        )
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error rotating secret: {e}')
        }   

    print("Secret rotated successfully")

    return {
        'statusCode': 200,
        'body': json.dumps('Secret rotated successfully')
    }

