#!/bin/bash
sudo yum update -y
sudo yum install git python3 python3-pip -y

git clone https://github.com/Rakowskiii/agh-cloud-simple-web-service /home/ec2-user/cloud
cd /home/ec2-user/cloud/python_app

python3 -m pip install -r requirements.txt

export SECRET_ID="${secret_id}"
export REGION="${region}"
export DB_NAME="${db_name}"

nohup python3 app.py > /var/log/myapp.log 2>&1 &


