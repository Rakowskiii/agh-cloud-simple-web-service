#!/bin/bash
sudo yum update -y
sudo yum install git -y
wget https://go.dev/dl/go1.23.4.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.23.4.linux-amd64.tar.gz
export HOME=/home/ec2-user
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
export GOCACHE=$GOPATH/.cache
mkdir -p $GOPATH
mkdir -p $GOCACHE

git clone https://github.com/Rakowskiii/agh-cloud-simple-web-service /home/ec2-user/cloud
cd /home/ec2-user/cloud/app

go env
go build -o app main.go 

yum install -y amazon-cloudwatch-agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:/cloudwatch-agent/config

nohup ./app > /var/log/myapp.log 2>&1 &