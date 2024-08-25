provider "aws" {
  region = "us-east-1"  # Change this to your desired region
}

# Create ECR Repository
resource "aws_ecr_repository" "example" {
  name                 = "example-repo"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

# Create S3 Bucket for Terraform State and TFVars
resource "aws_s3_bucket" "terraform_state" {
  bucket = "example-terraform-state-bucket"  # Change bucket name to a unique name
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# Save TFVars file in the S3 Bucket
resource "aws_s3_bucket_object" "tfvars" {
  bucket = aws_s3_bucket.terraform_state.bucket
  key    = "terraform.tfvars"
  source = "terraform.tfvars"  # Assuming tfvars file is in the same directory
}

# Create DynamoDB Table for State Locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# Backend configuration with hardcoded values
terraform {
  backend "s3" {
    bucket         = "example-terraform-state-bucket"  # Hardcoded bucket name
    key            = "terraform.tfstate"
    region         = "us-west-2"  # Change this to your desired region
    dynamodb_table = "terraform-locks"  # Hardcoded DynamoDB table name
    encrypt        = true
  }
}
