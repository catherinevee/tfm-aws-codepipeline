# Quick Start Guide

This guide will help you quickly deploy a CI/CD pipeline using the AWS CodePipeline Terraform module.

## Prerequisites

1. **AWS CLI** installed and configured
2. **Terraform** (version >= 1.0) installed
3. **AWS Account** with appropriate permissions

## Quick Deployment

### 1. Clone or Download the Module

```bash
git clone <repository-url>
cd tfm-aws-codepipeline/tfm-aws-codepipeline
```

### 2. Create a Basic Configuration

Create a file called `main.tf` with the following content:

```hcl
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
  region = "us-east-1"  # Change to your preferred region
}

module "cicd_pipeline" {
  source = "./tfm-aws-codepipeline"

  # Required variables
  project_name                = "my-app"
  environment                 = "dev"
  artifacts_bucket_name       = "my-app-artifacts-123456789012"  # Must be globally unique
  codecommit_repository_name  = "my-app-repo"

  # Common tags
  common_tags = {
    Environment = "dev"
    Project     = "my-app"
    Owner       = "your-team"
  }
}

output "pipeline_url" {
  value = module.cicd_pipeline.pipeline_url
}

output "repository_url" {
  value = module.cicd_pipeline.codecommit_clone_url_http
}
```

### 3. Deploy the Pipeline

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

### 4. Access Your Resources

After successful deployment, you can access:

- **CodePipeline**: Use the `pipeline_url` output
- **CodeCommit Repository**: Use the `repository_url` output
- **S3 Artifacts Bucket**: Check the `artifacts_bucket_name` output

## Next Steps

### 1. Add Your Source Code

```bash
# Clone the repository
git clone <repository-url-from-output>

# Add your application code
cd my-app-repo
# ... add your source code ...

# Commit and push
git add .
git commit -m "Initial commit"
git push origin main
```

### 2. Create a Buildspec File

Create a `buildspec.yml` file in your repository root:

```yaml
version: 0.2

phases:
  build:
    commands:
      - echo "Building application..."
      - echo "Build completed on `date`"
      
artifacts:
  files:
    - '**/*'
```

### 3. Monitor Your Pipeline

- Visit the CodePipeline console to monitor builds
- Check CloudWatch logs for detailed build information
- Set up notifications for pipeline events

## Advanced Configuration

For more advanced features, see the examples in the `examples/` directory:

- **Basic Example**: Simple pipeline setup
- **Advanced Example**: Full pipeline with CloudFormation deployment

## Troubleshooting

### Common Issues

1. **S3 Bucket Name Already Exists**
   - Change the `artifacts_bucket_name` to something unique

2. **IAM Permission Errors**
   - Ensure your AWS credentials have the necessary permissions

3. **CodeBuild Timeout**
   - Increase the `build_timeout` variable

### Getting Help

- Check the CloudWatch logs for detailed error messages
- Review the IAM roles and policies
- Validate your buildspec file

## Clean Up

To remove all resources:

```bash
terraform destroy
```

## Support

For issues and questions:
- Check the main README.md file
- Review the examples directory
- Open an issue in the repository 