/*
defines outputs from resources inside the modul
...outputs defined here will be available for capture/to be exposed
for use wherever the module is invoked, by defining it
 example:
    output "name_the_output_z_environment" {
      description = "The x output of of the y instance in the z environment"
      value       = module.ec2.instance_id
    }
*/

output "webserver_instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.webserver.id
}

output "public_ip" {
  description = "The public IP address of the EC2 webserver instance"
  value       = aws_instance.webserver.public_ip
}
