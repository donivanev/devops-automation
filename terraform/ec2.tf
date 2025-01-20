provider "aws" {
  region = "eu-central-1"
}

data "external" "home" {
  program = ["sh", "-c", "echo '{\"value\":\"'$HOME'\"}'"]
}

resource "aws_key_pair" "ansible_key_pair" {
  key_name   = "ansible_key_pair"
  public_key = tls_private_key.ansible_key.public_key_openssh
}

resource "aws_instance" "webserver" {
  ami           = "ami-0a628e1e89aaedf80"
  instance_type = "t2.micro"
  security_groups = [ aws_security_group.allow_web_traffic.name ]

  key_name = aws_key_pair.ansible_key_pair.key_name
  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "web_server"
    Role = "webserver"
    Public = "true"
  }
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.yml"
  content  = templatefile("${path.module}/inventory.tpl", {
    webserver = aws_instance.webserver.public_ip
    private_key_filepath = "~/.ssh/id_rsa"
  })
}

resource "aws_security_group" "allow_web_traffic" {
  name        = "allow_web_traffic"
  description = "Allow inbound web traffic"

  ingress {
    description = "TLS from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web_traffic"
  }
}

output webserver {
  value = aws_instance.webserver.public_dns
}