# ==============================================================================
# Test Configuration for AWS CodePipeline CI/CD Module
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
# Test CI/CD Pipeline
# ==============================================================================

module "test_pipeline" {
  source = "../"

  # Required variables
  project_name                = "test-pipeline"
  environment                 = "test"
  artifacts_bucket_name       = "test-pipeline-artifacts-${data.aws_caller_identity.current.account_id}"
  codecommit_repository_name  = "test-pipeline-repo"

  # Minimal configuration for testing
  build_timeout = 30
  deploy_enabled = false  # Disable deployment for testing
  cloudformation_deploy_enabled = false  # Disable CloudFormation for testing
  enable_notifications = false  # Disable notifications for testing
  enable_pipeline_monitoring = false  # Disable monitoring for testing
  enable_pipeline_triggers = false  # Disable triggers for testing

  # Common tags
  common_tags = {
    Environment = "test"
    Project     = "test-pipeline"
    Owner       = "test-team"
    ManagedBy   = "terraform"
    Purpose     = "testing"
  }
}

# ==============================================================================
# Data Sources
# ==============================================================================

data "aws_caller_identity" "current" {}

# ==============================================================================
# Outputs for Testing
# ==============================================================================

output "test_pipeline_name" {
  description = "Name of the test CodePipeline"
  value       = module.test_pipeline.codepipeline_name
}

output "test_repository_name" {
  description = "Name of the test CodeCommit repository"
  value       = module.test_pipeline.codecommit_repository_name
}

output "test_artifacts_bucket" {
  description = "Name of the test S3 bucket for artifacts"
  value       = module.test_pipeline.artifacts_bucket_name
}

output "test_module_summary" {
  description = "Summary of test resources"
  value       = module.test_pipeline.module_summary
} 