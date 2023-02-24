/*
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.54.0"
    }
  }
}
*/

provider "aws" {
  region = "eu-west-1"
}

resource "aws_s3_bucket" "works_state" {
    bucket = "works-up-and-running-state"

    # Prevent accidental deletion of this S3 bucket
    /*
    lifecycle {
        prevent_destroy = true
    }
    */
    force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "works_state" {
  bucket = aws_s3_bucket.works_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "works_state" {
  name           = "works-up-and-running-state"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

/*
terraform {
  backend "s3" {
    bucket = "works-up-and-running-state"
    key = "global/s3/terraform.tfstate"
    region = "eu-west-1"
    dynamodb_table = "works-up-and-running-state"
    encrypt = true
  }
}
*/


output "s3_bucket_arn" {
  value = aws_s3_bucket.works_state.arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.works_state.name
  description = "The name of the DynamoDB table"
}