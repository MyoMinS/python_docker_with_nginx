data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

data "aws_iam_role" "name" {
  name = "EC2InstanceRoleForSSM"
}

data "aws_key_pair" "name" {
  key_name = "ansible"
  include_public_key = true
}

data "aws_vpc" "name" {
  id = "vpc-0abac953ae05d5aa4"
}

data "aws_subnet" "name" {
  filter {
    name = "tag:Name"
    values = ["subnet-1a"]
  }
}

module "web_server_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"
  name        = "web-server"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = data.aws_vpc.name.id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]
}

#resource "aws_eip" "name" {
#  domain = "vpc"
#  instance = module.ec2-instance.id
#  depends_on = [ module.ec2-instance ]
#}

module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  ami = data.aws_ami.ubuntu.image_id
  instance_type          = var.type
  key_name               = data.aws_key_pair.name.key_name
  vpc_security_group_ids = [module.web_server_sg.security_group_id]
  subnet_id              = data.aws_subnet.name.id

  tags = {
    Name = "laravel"
    Terraform   = "true"
    Environment = "prod"
  }
}

resource "terraform_data" "id" {
  provisioner "local-exec" {
    command = <<EOT
      sed -i '' "s/^laravel ansible_host=.*/laravel ansible_host=$IP/" production.ini
      sleep 30
      ansible-playbook -i production.ini webservers.yml
    EOT
    environment = {
      IP = module.ec2-instance.public_ip
    }
    working_dir = abspath("../playbooks")
  }
}