// first destroy default vpc
resource "aws_default_vpc" "default" {
  force_destroy = true
}

resource "aws_vpc" "acg_vpc" {

    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "Hrishi's acg VPC"
    }  
}

resource "aws_subnet" "acg_subnet_public" {
  vpc_id     = aws_vpc.acg_vpc.id
  cidr_block = "10.0.0.0/17"

  tags = {
    Name = "Hrishi's public subnet"
  }
}

resource "aws_subnet" "acg_subnet_private" {
  vpc_id     = aws_vpc.acg_vpc.id
  cidr_block = "10.0.128.0/17"

  tags = {
    Name = "Hrishi's private subnet"
  }
}

resource "aws_instance" "web-server" {
  
  ami = data.aws_ami.rhel9.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.acg_subnet_public.id

  vpc_security_group_ids = [
      aws_security_group.web_sg.id
  ]

  user_data = file("userdata.tpl")

  tags = {
    Name = "Hrishi instance"
  }
}

resource "aws_security_group" "web_sg" {
    name        = "web_sg"
    description = "allow standard http and https ports inbound everything outbound"
    vpc_id = aws_vpc.acg_vpc.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 443
        to_port     = 443
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



resource "aws_internet_gateway" "acg-igw" {

  vpc_id = aws_vpc.acg_vpc.id

  tags = {
    "Name" = "acg igw"
  }
  
}

# resource "aws_internet_gateway_attachment" "acg-igw-attachment" {
  
#   internet_gateway_id = aws_internet_gateway.acg-igw.id
#   vpc_id = aws_vpc.acg_vpc.id

# }

resource "aws_lb" "hrishi-acg-nlb" {

  name = "hrishi-acg-nlb"
  internal = false
  load_balancer_type = "network"
  subnets = [ aws_subnet.acg_subnet_public.id ]
  
}

resource "aws_lb_target_group" "hrishi-lb-aws_lb_target_group" {
  
  name = "hrishi-lb-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.acg_vpc.id
}

resource "aws_lb_target_group_attachment" "acg-target-group-attachment" {
  
  target_group_arn = aws_lb_target_group.hrishi-lb-aws_lb_target_group.arn
  target_id = aws_instance.web-server.id
  port = 80
}


    
