provider "aws" {
  region = "us-east-1"
}

# Create ECR Repository
resource "aws_ecr_repository" "example_ecr" {
  name                 = "example-manas_repo"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

# Upload tfvars to the existing S3 bucket
resource "aws_s3_bucket_object" "tfvars" {
  bucket = "manas-ecr-terraform-state-bucket123"  # Use your hardcoded bucket name
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
    bucket         = "manas-ecr-terraform-state-bucket123"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
