terraform {

  backend "s3" {
    bucket = "card-website-terraform-project1"
    key    = "path/terraform.tfstate"
    region = "ap-south-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}



#Creating the new infrastructure
resource "aws_vpc" "project_vpc_mumbai" {
  cidr_block = "10.10.0.0/16"

 tags = {
    Name = "project_vpc_mumbai"
  }
}

#subenet 

#mumbai_subnet_1a


resource "aws_subnet" "subnet_1a_public" {
  vpc_id     = aws_vpc.project_vpc_mumbai.id
  cidr_block = "10.10.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "mumbai_subnet_1a_public"
  }
}


resource "aws_subnet" "subnet_1a_private" {
  vpc_id     = aws_vpc.project_vpc_mumbai.id
  cidr_block = "10.10.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "mumbai_subnet_1a_private"
  }
}

#mumbai_subnet_1b

resource "aws_subnet" "subnet_1b_public" {
  vpc_id     = aws_vpc.project_vpc_mumbai.id
  cidr_block = "10.10.2.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "mumbai_subnet_1b_public"
  }
}


resource "aws_subnet" "subnet_1b_private" {
  vpc_id     = aws_vpc.project_vpc_mumbai.id
  cidr_block = "10.10.3.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "mumbai_subnet_1b_private"
  }
}



#key_pair

resource "aws_key_pair" "mumbai_keys" {
  key_name   = "public_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCmn19YCgYbSEl6wXgV1gvGR9s8n0cVTjS8X2lnnJ92Z/aoRgeUO5zRrpk0nqqmo5Gj0rqSBDm3qc+4luCElRM8y4uQhQ2QW36HMR1lr5p0JLsT9tQNBbuFlZUml4ewicMmkHeaEV2cE6GpdN2/pm7zjdWqZz6O1Rnmy6OvZshzAtppyRoo6mpKDcKkK+77QuUjU3x7jfLpLO5zONerqrBXD5Vtv2XRv++AR430uuyK6Cbdbw7kNMRroLtqy6LJ7CzgxzrbZZr2R00hy16zaeciCMSUsd3eXDs6PoEn6rszQVcE4HlaXzxvh7TFTT3iwHhygnOmqMj4+zRrLSK+uaiuW7ao1UuIiolTPTHZ0whkxUYZcIBKY2rnsQo9q3US1f5TpScDUPIxzDFBruBo7kRtW0VajqpTnH3OTFEeNyRFPxfnlPmsLfvDgc6fXzwRO4obrmPUMSUtTVC9T5H99jPzG7qaI5FCeO964gvHUFF38vTJf6jLaIXm1XYIslFnVek= sharanagouda@DESKTOP-B81EITH"
}

#security group

resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_http_ssh"
  description = "Allow http and ssh inbound traffic"
  vpc_id      = aws_vpc.project_vpc_mumbai.id

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh_http"
  }
}


#create IG

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.project_vpc_mumbai.id

  tags = {
    Name = "Mumbai-vpc-IG"
  }
}

#RT

resource "aws_route_table" "mumbai_RT_Public" {
  vpc_id = aws_vpc.project_vpc_mumbai.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "mumbai-RT-Public"
  }
}


resource "aws_route_table" "mumbai_RT_Private" {
  vpc_id = aws_vpc.project_vpc_mumbai.id

  tags = {
    Name = "mumbai-RT-Private"
  }
}

resource "aws_route_table_association" "RT_asso_1a_public" {
  subnet_id      = aws_subnet.subnet_1a_public.id
  route_table_id = aws_route_table.mumbai_RT_Public.id
}


resource "aws_route_table_association" "RT_asso_1a_private" {
  subnet_id      = aws_subnet.subnet_1a_private.id
  route_table_id = aws_route_table.mumbai_RT_Private.id
}

resource "aws_route_table_association" "RT_asso_1b_public" {
  subnet_id      = aws_subnet.subnet_1b_public.id
  route_table_id = aws_route_table.mumbai_RT_Public.id
}


resource "aws_route_table_association" "RT_asso_1b_private" {
  subnet_id      = aws_subnet.subnet_1b_private.id
  route_table_id = aws_route_table.mumbai_RT_Private.id
}


#creating the instances via ASG and  we will attach the LB to it

resource "aws_launch_template" "LT-template-demo-terraform" {
  name = "LT-demo-terraform"
  image_id = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.micro"
  key_name = aws_key_pair.mumbai_keys.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
  user_data = filebase64("example.sh")


  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "demo-instance by terra"
    }
  }
}

# asg creation

resource "aws_autoscaling_group" "demo-asg" {
  vpc_zone_identifier = [aws_subnet.subnet_1a_public.id, aws_subnet.subnet_1b_public.id ]
  desired_capacity   = 2
  max_size           = 5
  min_size           = 2
  name = "demo-as-terraform"
  target_group_arns = [aws_lb_target_group.card-website-TG-terraform-2.arn]

  launch_template {
    id      = aws_launch_template.LT-template-demo-terraform.id
    version = "$Latest"
  }
}

# LB with ASG

resource "aws_lb_target_group" "card-website-TG-terraform-2" {
  name     = "card-website-TG-terraform-2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.project_vpc_mumbai.id
}


resource "aws_lb_listener" "card-website-listener-2" {
  load_balancer_arn = aws_lb.card-website-LB-terraform-2.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.card-website-TG-terraform-2.arn
  }
}

resource "aws_lb" "card-website-LB-terraform-2" {
  name               = "card-website-LB-terraform-2"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_ssh_http.id]
  subnets            = [aws_subnet.subnet_1a_public.id, aws_subnet.subnet_1b_public.id]


  tags = {
    Environment = "production"
  }
}









