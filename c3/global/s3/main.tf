provider "aws" {
    region = "us-east-1"
}

terraform {
    backend "s3" {
        bucket = "tur2-state-pa1ravi"
        key = "global/s3/terraform.tfstate"
        region = "us-east-1"

        dynamodb_table = "tur2-state-locks"
        encrypt = true
    }
}
resource "aws_s3_bucket" "terraform_state" {
  bucket = "tur2-state-pa1ravi"

  #prevent accidental deletion of this bucket
  lifecycle {
      prevent_destroy = true
  }

  #Enable versioning so that we can full revision hisotry of our state files
  versioning {
      enabled = true
  }

  #Enable server side encryption by default
  server_side_encryption_configuration {
      rule {
          apply_server_side_encryption_by_default {
              sse_algorithm = "AES256"
          }
      }
  }
}

resource "aws_dynamodb_table" "tur2_locks" {
  name = "tur2-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
      name = "LockID"
      type = "S"
  }
}
