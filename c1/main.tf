provider "aws" {
    region = "us-east-1"
}

# TF-UPGRADE-TODO: In Terraform v0.11 and earlier, it was possible to begin a
# resource name with a number, but it is no longer possible in Terraform v0.12.
#
# Rename the resource and run `terraform state mv` to apply the rename in the
# state. Detailed information on the `state move` command can be found in the
# documentation online: https://www.terraform.io/docs/commands/state/mv.html

variable "sg_port" {
  description = "This port will be used for http requestes"
  type = number
  default = 8080
}

variable "alb_sg_port" {
  description = "This port will be used for http requestes"
  type = number
  default = 80
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}


resource "aws_launch_configuration" "exampleLC" {
    image_id = "ami-07ebfd5b3428b6f4d"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.asgSG.id]
    
    user_data = <<-EOF
                #!/bin/bash
                echo "whatsappp" > index.html
                nohup busybox httpd -f -p ${var.sg_port} &
                EOF
    #Required when using a launch configuration with an ASG
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "exampleASG" {
  launch_configuration = aws_launch_configuration.exampleLC.name
  vpc_zone_identifier = data.aws_subnet_ids.default.ids

  target_group_arns = [aws_lb_target_group.albTG.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 4

  tag {
    key = "Name"
    value = "terraform-example-ASG"
    propagate_at_launch = true
  }
}


resource "aws_security_group" "asgSG" {
  name = "terraform-example-instance"

  ingress {
      from_port = var.sg_port
      to_port  = var.sg_port
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "exampleLB" {
  name = "terraform-alb-example"
  load_balancer_type = "application"
  subnets = data.aws_subnet_ids.default.ids
  security_groups = [aws_security_group.albSG.id]
}

resource "aws_lb_listener" "httpListener" {
  load_balancer_arn = aws_lb.exampleLB.arn
  port = var.alb_sg_port
  protocol = "HTTP"

  #By Default, Return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = 404
    }
  }
}

resource "aws_security_group" "albSG" {
  name = "terraform-ALB-SG"

  #Allow inbound traffic on port 80
  ingress {
    from_port = var.alb_sg_port
    to_port = var.alb_sg_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow all outbound requests
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "albTG" {
  name = "terraform-alb-tg"
  port = var.sg_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "albLR" {
  listener_arn = aws_lb_listener.httpListener.arn
  priority = 100

  condition {
    field = "path-pattern"
    values = ["*"]
  }

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.albTG.arn
  }
}

output "alb_dns_name" {
  value = aws_lb.exampleLB.dns_name
  description = "DNS endpoint of the load balancer"
}
