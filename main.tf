resource "aws_instance" "webserver" { 
    ami = "ami-0b8b44ec9a8f90422"
    instance_type = "t2.micro"
    tags = {
      name= "nginx Server"
      description="Will Run Webserver of Ngnix Testing"
    }
    user_data = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install nginx -y
    sudo systemctl enable nginx
    sudo systemctl start nginx
    EOF
    key_name = aws_key_pair.ssh.key_name
    vpc_security_group_ids = [aws_security_group.ssh-access.id]
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "ssh" {
  key_name = "ssh-ec2"
  public_key = tls_private_key.ssh.public_key_openssh
  
}



resource "aws_security_group" "ssh-access" {
  name = "ssh-access"
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
output "publicip" {
  value = aws_instance.webserver.public_ip
}
provider "aws" {
  region = "us-east-2"
  secret_key = var.secret_key
  access_key = var.access_key
}