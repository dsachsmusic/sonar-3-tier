output "dev_webserver_instance_id" {
  description = "The ID of the EC2 instance in the dev environment"
  value       = module.ec2.webserver_instance_id
}

output "dev_public_ip" {
  description = "The public IP address of the EC2 instance in the dev environment"
  value       = module.ec2.public_ip
}