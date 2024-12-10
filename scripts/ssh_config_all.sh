
if [ ! -d "/tmp/web_app_cloud" ]; then
    mkdir /tmp/web_app_cloud
fi
terraform output --raw ssh_private_key > /tmp/web_app_cloud/priv_key.pem
chmod 600 /tmp/web_app_cloud/priv_key.pem


terraform output --raw ssh_config > /tmp/web_app_cloud/ssh_config
