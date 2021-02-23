variable "web-server-port" {
  description = "port our web server will run on"
  type        = number
  default     = 8080
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

output "public_ip" {
  description = "Public IP address of the web server"
  value       = aws_instance.example.public_ip
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port   = var.web-server-port
    to_port     = var.web-server-port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "example" {
  image_id        = "ami-0c55b159cbfafe1f0"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance.id]
  lifecycle {
    create_before_destroy = true
  }

  user_data = <<-EOF
    #!/bin/bash
    echo "Hi Mom" > index.html
    nohup busybox httpd -f -p ${var.web-server-port} &
    EOF
}

resource "aws_auto_scaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier  = data.aws_subnet_ids.default.ids

  min_size = 2
  max_size = 10

  tag {
    key                 = "name"
    value               = "example_name"
    propogate_at_launch = true
  }
}
