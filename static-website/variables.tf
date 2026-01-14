variable "aws_region" {
  description = "AWS region for resources"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket for static website"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "static-website"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "default_root_object" {
  description = "Default root object for CloudFront distribution"
  type        = string
  default     = "index.html"
}

variable "cloudfront_price_class" {
  description = "CloudFront distribution price class"
  type        = string
  default     = "PriceClass_200"
  validation {
    condition = contains([
      "PriceClass_All",
      "PriceClass_200",
      "PriceClass_100"
    ], var.cloudfront_price_class)
    error_message = "Price class must be PriceClass_All, PriceClass_200, or PriceClass_100."
  }
}

variable "cache_policy_id" {
  description = "CloudFront cache policy ID"
  type        = string
}
