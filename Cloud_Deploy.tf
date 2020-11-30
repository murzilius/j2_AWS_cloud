provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu_latest.id           //"ami-0a91cd140a1fc148a"
  instance_type = "t2.micro"
  tags = {
    Name = "Server Test"
  }
  vpc_security_group_ids = [ aws_security_group.test_security_group.id ]
  key_name="AWS_for_test"
}

resource "aws_instance" "deploy" {
  ami           = data.aws_ami.ubuntu_latest.id
  instance_type = "t2.micro"
  tags = {
    Name = "Server Deploy"
  }

  vpc_security_group_ids = [ aws_security_group.test_security_group.id ]
  depends_on = [ aws_instance.web ]
  key_name="AWS_for_test"
}

resource "aws_security_group" "test_security_group" {
  name        = "testroot"
  description = "test_sec_group"

  dynamic "ingress" {
    for_each = ["80", "22", "8080"]
    content {
      from_port   = ingress.value
      protocol    = "tcp"
      to_port     = ingress.value
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "AWS" {
  key_name   = "AWS_for_test"
  public_key = file("d:\\Job2\\AWS\\keys\\AWS.pub")
}
resource "aws_eip" "deploy" {
  instance = aws_instance.deploy.id
}
data "aws_ami" "ubuntu_latest"{
 owners = ["099720109477"]
 most_recent = true
filter {
  name = "name"
  values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
}
}
output "public_ip_for_deploy" {
  value = aws_instance.web.public_ip
}