provider "aws" {
  region = "us-east-2"
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress = [ {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "none"
    from_port = 8080
    ipv6_cidr_blocks = [ "::/0" ]
    prefix_list_ids = [ "" ]
    protocol = "tcp"
    security_groups = [ "" ]
    self = false
    to_port = 8080
  } ]
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ "aws_security_group.instance.id" ]

  tags = {
    name = "phils_example_tag"
  }

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World" > index . html nohup busybox httpd f p 8080 &
    EOF
}
