terraform {
  backend "s3" {
    bucket       = "my-tf-backend-bucket-name"
    key          = "terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
  }
}
