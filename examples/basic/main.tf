# ==============================================================================
# Basic Example - AWS CodePipeline CI/CD Module
# ==============================================================================

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
  region = "us-east-1"
}

# ==============================================================================
# Basic CI/CD Pipeline
# ==============================================================================

module "basic_pipeline" {
  source = "../../"

  # Required variables
  project_name                = "basic-web-app"
  environment                 = "dev"
  artifacts_bucket_name       = "basic-web-app-artifacts-${data.aws_caller_identity.current.account_id}"
  codecommit_repository_name  = "basic-web-app-repo"

  # Common tags
  common_tags = {
    Environment = "dev"
    Project     = "basic-web-app"
    Owner       = "devops-team"
    ManagedBy   = "terraform"
  }
}

# ==============================================================================
# Data Sources
# ==============================================================================

data "aws_caller_identity" "current" {}

# ==============================================================================
# Outputs
# ==============================================================================

output "pipeline_name" {
  description = "Name of the created CodePipeline"
  value       = module.basic_pipeline.codepipeline_name
}

output "repository_name" {
  description = "Name of the created CodeCommit repository"
  value       = module.basic_pipeline.codecommit_repository_name
}

output "repository_clone_url_http" {
  description = "HTTP clone URL for the CodeCommit repository"
  value       = module.basic_pipeline.codecommit_clone_url_http
}

output "artifacts_bucket" {
  description = "Name of the S3 bucket for artifacts"
  value       = module.basic_pipeline.artifacts_bucket_name
}

output "pipeline_url" {
  description = "URL to view the pipeline in AWS Console"
  value       = module.basic_pipeline.pipeline_url
} 