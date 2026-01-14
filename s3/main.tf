resource "aws_s3_bucket" "my-tf-backend-bucket" {
  bucket = var.bucket_name
  region = var.region

  tags = {
    Name        = var.bucket_name
    Environment = "Dev"
  }
}