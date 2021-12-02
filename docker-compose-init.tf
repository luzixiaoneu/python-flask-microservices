provider "aws" {
  profile = "default"
  region  = "us-east-2"
}
variable "ingressrules" {
  type    = list(number)
  default = [80, 443, 22, 8080]
}

resource "aws_security_group" "web_traffic" {
  name        = "Allow web traffic"
  description = "Allow ssh and standard http/https ports inbound and everything outbound"

  dynamic "ingress" {
    iterator = port
    for_each = var.ingressrules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Terraform" = "true"
  }
}
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "jenkins" {
 ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.large"
  security_groups = [aws_security_group.web_traffic.name]
  key_name        = "cloud-fall21"



	provisioner "file" {

	source = "docker-compose.yml"
	destination = "~/docker-compose.yml"
	}

	
	provisioner "remote-exec" {

	inline = [
	<<EOF
	 yes | sudo apt-get update
 yes | sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
	 yes | curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


	yes | sudo apt-get update
 yes | sudo apt-get install docker-ce docker-ce-cli containerd.io
	
	 yes | sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

	yes | sudo chmod +x /usr/local/bin/docker-compose
	yes | sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
	yes | sudo docker-compose -f ~/docker-compose.yml up
	EOF
	]

	}
	

connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("~/init/cloud-fall21.pem")
    }	 

  tags = {
    "Name"      = "Jenkins_Server"
    "Terraform" = "true"
  }
}



