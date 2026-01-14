# Static Website Terraform Configuration

This Terraform configuration deploys a secure, scalable static website on AWS using Amazon S3 for storage and Amazon CloudFront for content delivery. The setup includes Origin Access Control (OAC) for secure access, server-side encryption.

## Architecture

- **S3 Bucket**: Stores static website files with versioning, encryption, and public access blocked
- **CloudFront Distribution**: CDN for fast global content delivery with HTTPS
- **Origin Access Control**: Secure access from CloudFront to S3 without public bucket policies
- **Terraform Backend**: Remote state management using S3.

## File Structure


static-website-project/
├── README.md                     
└── static-website/
      ├── main.tf                 # Main Terraform configuration (S3, CloudFront, etc.)
      ├── variables.tf            # Variable definitions
      ├── terraform.tfvars        # Variable values (customize here)
      ├── outputs.tf              # Output definitions
      ├── tfbekend.tf             # Backend configuration for remote state
└── s3/                           # Code to create S3 backend bucket ()
      ├── main.tf
      ├── provider.tf
      └── variable.tf

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- AWS account with permissions for:
  - S3 bucket creation and management
  - CloudFront distribution creation

## Quick Start

1. **Clone or navigate to the project directory**

2. **Configure variables**:
   Edit `terraform.tfvars` to customize:

   aws_region                = "ap-south-1"
   bucket_name              = "my-unique-bucket-name" (change accordingly)
   project_name             = "my-project-website" (change accordingly)
   environment              = "my-environment-name" (change accordingly)
   cloudfront_price_class   = "PriceClass_200" (change accordingly)

3. **Initialize Terraform**:

   terraform init

4. **Review the plan**:

   terraform plan

5. **Apply the configuration**:

   terraform apply

6. **Upload your website files**:
   After deployment, upload your static files to the S3 bucket:

   aws s3 sync ./website-files s3://your-bucket-name --delete

## Variables

| Variable                 | Description                       | Type   | Default          | Required |
|--------------------------|-----------------------------------|--------|------------------|----------|
| `aws_region`             | AWS region for resources          | string | -                | Yes      |
| `bucket_name`            | Unique S3 bucket name             | string | -                | Yes      |
| `project_name`           | Project identifier                | string | "static-website" | No       |
| `environment`            | Deployment environment            | string | -                | Yes      |
| `default_root_object`    | Default file served by CloudFront | string | "index.html"     | No       |
| `cloudfront_price_class` | CloudFront pricing tier           | string | "PriceClass_200" | No       |
| `cache_policy_id`        | CloudFront cache policy ID        | string | -                | Yes      |

## Outputs

| Output                           | Description                    |
|----------------------------------|--------------------------------|
| `s3_bucket_name`                 | S3 bucket name                 |
| `s3_bucket_arn`                  | S3 bucket ARN                  |
| `s3_bucket_domain_name`          | S3 bucket domain name          |
| `s3_bucket_regional_domain_name` | S3 bucket regional domain name |
| `cloudfront_distribution_id`     | CloudFront distribution ID     |
| `cloudfront_distribution_arn`    | CloudFront distribution ARN    |
| `cloudfront_domain_name`         | CloudFront domain name         |
| `cloudfront_hosted_zone_id`      | CloudFront hosted zone ID      |
| `origin_access_control_id`       | Origin Access Control ID       |
| `website_url`                    | Public website URL             |

## Backend Configuration

The Terraform state is stored remotely in S3 with DynamoDB locking. The backend is configured in `tfbekend.tf`. Ensure the S3 bucket exist before running `terraform init`.

To create the backend resources, use the module in the `s3/` subdirectory:

cd s3
terraform init
terraform apply -var="bucket_name=my-tf-backend-bucket" -var="region=ap-south-1"

## Security Features

- S3 bucket public access blocked
- Server-side encryption enabled
- CloudFront HTTPS enforcement
- Origin Access Control for secure S3 access

## Customization

- **Custom Domain**: Add Route53 and ACM resources for custom domains
- **Additional Origins**: Extend CloudFront for multiple S3 buckets or origins
- **Advanced Caching**: Modify cache policies for specific file types
- **Logging**: Enable CloudFront access logging to S3

## Cleanup

To destroy all resources:

terraform destroy

**Note**: This will permanently delete the S3 bucket and all its contents.

## Troubleshooting

- **Bucket name conflicts**: Ensure `bucket_name` is globally unique
- **Permissions errors**: Verify AWS credentials and IAM permissions

## Contributing

Update variables, add resources, or modify configurations as needed. Run `terraform validate` and `terraform plan` before applying changes.

