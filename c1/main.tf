provider "aws" {
    region = "us-east-1"
}

# TF-UPGRADE-TODO: In Terraform v0.11 and earlier, it was possible to begin a
# resource name with a number, but it is no longer possible in Terraform v0.12.
#
# Rename the resource and run `terraform state mv` to apply the rename in the
# state. Detailed information on the `state move` command can be found in the
# documentation online: https://www.terraform.io/docs/commands/state/mv.html

resource "aws_instance" "example" {
    ami = "ami-07ebfd5b3428b6f4d"
    instance_type = "t2.micro"

    tags = {
        Name = "terraform-example"
    }
}