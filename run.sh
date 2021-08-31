#!/bin/bash

########## create ssh key ##########
SSH_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 6 | head -n 1)

aws ec2 create-key-pair \
--key-name $SSH_KEY \
--region "us-east-1" \
--query "KeyMaterial" \
--output text > ~/keys/$SSH_KEY.pem

chmod 600 ~/keys/$SSH_KEY.pem

cowsay "ssh-key made" | lolcat

########## append to ec2.tf ##########
cat << _break > ec2.tf
provider "aws" {
  region  = "us-east-1"
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
  owners = ["099720109477"] # Canonical
}
resource "aws_security_group" "sg" {
  name = "sg"
  ingress {
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
}
resource "aws_instance" "myec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.xlarge"
  user_data = file("./userdata.sh")
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name = "$SSH_KEY"
  root_block_device {
    volume_size = 40
  }

  tags = {
    Name = "myec2"
  }
}
_break

########## create destroy.sh ##########
cat << _break > destroy.sh
#!/bin/bash
terraform destroy -auto-approve
aws ec2 delete-key-pair --key-name $SSH_KEY --region us-east-1
cowsay "ssh-key destroyed" | lolcat
rm ~/keys/$SSH_KEY.pem
rm ./destroy.sh
rm ./ec2.tf
cowsay "files delete" | lolcat
_break

cowsay "files created" | lolcat

########## run terraform ##########
terraform init
terraform apply -auto-approve
PUBLIC_IP_ADDRESS=$(aws ec2 describe-instances \
--filter "Name=key-name,Values=$SSH_KEY" \
--query "Reservations[*].Instances[*].PublicIpAddress" \
--output text \
--region us-east-1)

echo "ssh -i ~/keys/$SSH_KEY.pem ubuntu@$PUBLIC_IP_ADDRESS"
