#!/bin/bash
sudo yum update -y
sudo yum install git -y
wget https://go.dev/dl/go1.23.4.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.23.4.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

git clone https://github.com/Rakowskiii/agh-cloud-simple-web-service
cd agh-cloud-simple-web-service/app
go run main.go