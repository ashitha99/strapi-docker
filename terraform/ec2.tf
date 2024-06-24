provider "aws" {
  region = var.region
}

variable "private_key_path" {
  description = "Path to the private key file"
  type        = string
}

variable "region" {
  default = "us-east-2"
}

variable "ami" {
  default = "ami-09040d770ffe2224f"
}

resource "aws_security_group" "docker_sg" {
  description = "Security group for Strapi EC2 instance"
  name        = "docker_sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "strapi-docker" {
  ami                    = var.ami
  instance_type          = "t2.medium"
  key_name               = "docker-test"
  vpc_security_group_ids = [aws_security_group.docker_sg.id]

  tags = {
    Name = "strapi-docker"
  }

  provisioner "remote-exec" {
  inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo apt-get install git -y",
      "sudo docker run -d -p 80:80 -p 1337:1337 veera1016/strapi:1.0.0",
  ]
}


    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }

output "instance_ip" {
  value = aws_instance.strapi-docker.public_ip
}
