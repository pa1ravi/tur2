provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "tur2-state-pa1ravi"
    key    = "stage/data-stores/mysql/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "tur2-state-locks"
    encrypt        = true
  }
}

resource "aws_db_instance" "examplemysql" {
  identifier_prefix = "tur2"
  engine            = "mysql"
  allocated_storage = 10
  instance_class    = "db.t2.micro"
  name              = "example_database"
  username          = "admin"

  #Password setting will follow
  password = data.aws_secretsmanager_secret_version.db_password.secret_string
}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "mysql-master-password-stage"
}
