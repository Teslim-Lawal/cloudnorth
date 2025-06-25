# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = "eu-north-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_instance" "frontend" {
  ami           = "ami-05fcfb9614772f051"
  instance_type = "t3.micro"
  key_name      = "cloudnorth-key"

  tags = {
    Name = "frontend"
  }
}


resource "aws_instance" "backend" {
  ami           = "ami-05fcfb9614772f051"
  instance_type = "t3.micro"
  key_name      = "cloudnorth-key"

  tags = {
    Name = "backend"
  }
}


resource "aws_s3_bucket" "static_files" {
  bucket = "cloudnorth-static-content"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "static_files" {
  bucket                  = aws_s3_bucket.static_files.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.static_files.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.static_files.arn}/*"
      }
    ]
  })
}

resource "aws_db_instance" "db" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "password123"
  skip_final_snapshot  = true
}

# variables.tf
variable "region" {
  default = "eu-north-1"
}

# outputs.tf
output "frontend_ip" {
  value = aws_instance.frontend.public_ip
}

output "backend_ip" {
  value = aws_instance.backend.public_ip
}