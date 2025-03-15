output "instance_public_ip" {
    description = "Public IP of the EC2 instances"    
    value = [for instance in aws_instance.app_server : "Test at http://${instance.public_ip}"]
}