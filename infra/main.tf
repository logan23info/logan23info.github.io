terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  cloud {
    hostname     = "app.terraform.io"
    organization = "logan23info"
    workspaces {
      name = "threat-wiki-infra"
    }
  }
}

provider "aws" { region = var.aws_region }

resource "random_id" "suffix" { byte_length = 4 }

resource "aws_s3_bucket" "hugo_backup" {
  bucket = "${var.project_name}-hugo-backup-${random_id.suffix.hex}"
  tags   = { Project = var.project_name, Environment = "production", ManagedBy = "opentofu" }
}

resource "aws_s3_bucket_versioning" "hugo_backup" {
  bucket = aws_s3_bucket.hugo_backup.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_lifecycle_configuration" "hugo_backup" {
  bucket = aws_s3_bucket.hugo_backup.id
  rule {
    id     = "expire-old-builds"
    status = "Enabled"
    filter {}
    expiration { days = 30 }
    noncurrent_version_expiration { noncurrent_days = 7 }
  }
}

resource "aws_s3_bucket_public_access_block" "hugo_backup" {
  bucket                  = aws_s3_bucket.hugo_backup.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
