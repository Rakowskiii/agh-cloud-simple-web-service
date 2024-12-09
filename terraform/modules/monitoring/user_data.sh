#!/bin/bash
sudo yum update -y
sudo yum upgrade -y
sudo yum install git python3 python3-pip -y

set -e


# Ouput all log
exec > >(tee /var/log/user-data.log|logger -t user-data-extra -s 2>/dev/console) 2>&1

# Configure Cloudwatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# Use cloudwatch config from SSM
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
-a fetch-config \
-m ec2 \
-c ssm:${ssm_cloudwatch_config} -s

echo 'Done initialization'

git clone https://github.com/Rakowskiii/agh-cloud-simple-web-service /home/ec2-user/cloud
cd /home/ec2-user/cloud/python_app

python3 -m pip install -r requirements.txt

export SECRET_ID="${secret_id}"
export REGION="${region}"
export DB_NAME="${db_name}"


nohup python3 app.py > /var/log/myapp.log 2>&1 &