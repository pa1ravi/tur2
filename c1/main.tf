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

resource "aws_instance" "example" {
    ami = "ami-07ebfd5b3428b6f4d"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.exampleinstance.id]
    
    user_data = <<-EOF
                #!/bin/bash
                echo "whatsappp" > index.html
                nohup busybox httpd -f -p ${var.sg_port} &
                EOF

    tags = {
        Name = "terraform-example"
    }
}

resource "aws_security_group" "exampleinstance" {
  name = "terraform-example-instance"

  ingress {
      from_port = var.sg_port
      to_port  = var.sg_port
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
  value = aws_instance.example.public_ip
  description = "Public IP Address of the web server"
}
