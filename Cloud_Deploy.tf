provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu_latest.id           //"ami-0a91cd140a1fc148a"
  instance_type = "t2.micro" //Is A Free instance
  tags = {
    Name = "Server Test for Web"
  }
  vpc_security_group_ids = [ aws_security_group.test_security_group.id ]
  key_name="AWS_for_test"
  
}

resource "aws_instance" "deploy" {
  ami           = data.aws_ami.ubuntu_latest.id
  instance_type = "t2.micro"
  tags = {
    Name = "Server Test for Deploy"
  }

  vpc_security_group_ids = [ aws_security_group.test_security_group.id ]
  depends_on = [ aws_instance.web ] //Start order - after web
  key_name="AWS_for_test"
  user_data = templatefile("deploy.sh.tmpl", {public_ip_for_Web = aws_instance.web.public_ip})//Script for wake up ansible and get Credentials
  
}

resource "aws_security_group" "test_security_group" {
  name        = "test Security Group"
  description = "To allow Web Access"

  dynamic "ingress" {
    for_each = ["80", "22", "8080"] //Allow ports for Nginx, Jenkins, SSH
    content {
      from_port   = ingress.value
      protocol    = "tcp"
      to_port     = ingress.value
      cidr_blocks = ["0.0.0.0/0"] //allow to every IP  from outside network 
    }
  }

  egress {
    from_port   = 0 //Every traffic to every IP to outter network is avaliable
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "AWS" {
  key_name   = "AWS_for_test"
  public_key = file("d:\\Job2\\AWS\\keys\\AWS.pub") //give servers Public Key
}

resource "aws_eip" "web" {
  instance = aws_instance.web.id //Assign Elastic IP to Deploy Server DO IT ONCE!!!!!!!!!!!!
}

data "aws_ami" "ubuntu_latest"{     //Take latest ubuntu server 20 Image
 owners = ["099720109477"]
 most_recent = true
filter {
  name = "name"
  values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
}
}
output "public_ip_for_Web" {     //output public IP for Deploy server
  value = aws_instance.web.public_ip
}
output "public_ip_for_Deploy" {     //output public IP for Deploy server
  value = aws_instance.deploy.public_ip
}
/*variable "AWS_private" {
  type    = string
  default = "${env.AWS_private}"
}
output "AWS_private" {     //output public IP for Deploy server
  value = "${env.AWS_private}"
  }
 */ 