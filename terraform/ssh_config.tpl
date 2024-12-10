### First jump host. Directly reachable
Host bastion
  User ec2-user
  HostName ${bastion_public_ip}
  IdentityFile /tmp/web_app_cloud/priv_key.pem


%{ for instance in web_apps_ips ~}
Host ${instance.private_ip}
  User ec2-user
  HostName ${instance.private_ip}
  ProxyJump bastion
  IdentityFile /tmp/web_app_cloud/priv_key.pem
%{ endfor ~}


