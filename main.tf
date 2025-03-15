# Provider Block
provider "aws" {
    profile = "default"
    region = "eu-west-2"
}

# HTTP Security Group Block
resource "aws_security_group" "app_sg" {
    name = "HTTP_new"
    
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# SSH Security Group Block
resource "aws_security_group" "app_sg_2" {
    name = "SSH"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0" ]
    }
}

# EC2 Resource Block
resource "aws_instance" "app_server" {
    count = 3
    ami = "ami-084725666251e790b"
    instance_type = var.ec2_instance_type
    associate_public_ip_address = true
    
    security_groups = [ aws_security_group.app_sg.name, aws_security_group.app_sg_2.name ]
    user_data = <<-EOF
    #!/bin/bash -ex

    # Install required packages
    sudo yum install nginx -y
    sudo yum install git -y
    sudo yum install java-21 -y
    
    # Configure nginx
    echo "<h1>This is my new server</h1>" > /usr/share/nginx/html/index.html
    sudo systemctl enable nginx
    sudo systemctl start nginx
    
    # Configure git
    sudo git config --system user.name "anzieri"
    sudo git config --system user.email "amaranyanzi1@gmail.com"
    
    # Clone and run Spring application
    sudo git clone "https://github.com/anzieri/Spring_AWS_EC2_LB_endpoints.git"
    cd Spring_AWS_EC2_LB_endpoints/executable
    sudo nohup java -jar bimo-0.0.1-SNAPSHOT.jar > output.log 2>&1 &
    EOF
    
    tags = {
        Name = "${var.instance_name}-${count.index}"
    }
}