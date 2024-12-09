output "web_instances_ips" {
  value = module.web_app.web_instances_ips
}

output "bast_instance_ip" {
  value = module.bastion.bast_instance_ip
}

output "database_endpoint" {
  value = module.database.db_endpoint
}

output "web_app_url" {
  value = module.web_app.alb_dns_name
}

output "ssh_private_key" {
  value     = tls_private_key.web_app_ssh_private_key.private_key_pem
  sensitive = true
}


output "ssh_config" {
  value = templatefile("ssh_config.tpl", {
    bastion_public_ip = module.bastion.bast_instance_ip.public_ip,
    web_apps_ips = module.web_app.web_instances_ips
  })
  sensitive = true
}

output "ssh_connect_setup" {
  value = "../scripts/ssh_config_all.sh"
}


output "ssh_connect_command" {
  value = "ssh -F /tmp/web_app_cloud/ssh_config -i /tmp/web_app_cloud/priv_key.pem ec2-user@<bastion_public_or_web_serv_private_ip>"
}


