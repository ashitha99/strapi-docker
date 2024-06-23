variable "private_key_path" {
  description = "Path to the private key file"
  type        = string
}

resource "aws_security_group" "checking_sg" {
  description = "Security group for Strapi EC2 instance"

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
  ami           = "ami-04b70fa74e45c3917"  # Correct AMI ID for ap-south-1
  instance_type = "t2.medium"              # Changed to t2.medium
  key_name      = "strapi-docker"                  # Your key pair name
  vpc_security_group_ids = [aws_security_group.checking_sg.id]

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
      "sudo docker run -d -p 80:80 -p 1337:1337 ashitha1999/strapi:1.0.0",
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
