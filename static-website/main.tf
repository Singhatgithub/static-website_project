terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}

# S3 Bucket for static website
resource "aws_s3_bucket" "static_website" {
  bucket = var.bucket_name

  tags = {
    Name        = "Static Website Bucket"
    Environment = var.environment
    Project     = var.project_name
  }
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "static_website_versioning" {
  bucket = aws_s3_bucket.static_website.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "static_website_encryption" {
  bucket = aws_s3_bucket.static_website.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "static_website_pab" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Ownership Controls
resource "aws_s3_bucket_ownership_controls" "static_website_ownership" {
  bucket = aws_s3_bucket.static_website.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# CloudFront Origin Access Control
resource "aws_cloudfront_origin_access_control" "static_website_oac" {
  name                              = "${var.project_name}-oac"
  description                       = "OAC for ${var.project_name} static website"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "static_website_distribution" {
  origin {
    domain_name              = aws_s3_bucket.static_website.bucket_regional_domain_name
    origin_id                = "${aws_s3_bucket.static_website.id}-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.static_website_oac.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.default_root_object
  price_class         = var.cloudfront_price_class

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "${aws_s3_bucket.static_website.id}-origin"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    cache_policy_id = var.cache_policy_id

    # Disable WAF
    trusted_key_groups = []
    trusted_signers    = []
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    ssl_support_method             = "vip"
    minimum_protocol_version       = "TLSv1"
  }

  tags = {
    Name        = "${var.project_name} CloudFront Distribution"
    Environment = var.environment
    Project     = var.project_name
  }

  depends_on = [aws_s3_bucket_public_access_block.static_website_pab]
}

# S3 Bucket Policy for CloudFront OAC
resource "aws_s3_bucket_policy" "static_website_policy" {
  bucket = aws_s3_bucket.static_website.id

  policy = jsonencode({
    Version = "2008-10-17"
    Id      = "PolicyForCloudFrontPrivateContent"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.static_website.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.static_website_distribution.arn
          }
        }
      }
    ]
  })

  depends_on = [aws_cloudfront_distribution.static_website_distribution]
}
