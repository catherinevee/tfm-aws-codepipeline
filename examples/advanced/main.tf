# ==============================================================================
# Advanced Example - AWS CodePipeline CI/CD Module
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
# Advanced CI/CD Pipeline with CloudFormation
# ==============================================================================

module "advanced_pipeline" {
  source = "../../"

  # Required variables
  project_name                = "advanced-web-app"
  environment                 = "prod"
  artifacts_bucket_name       = "advanced-web-app-artifacts-${data.aws_caller_identity.current.account_id}"
  codecommit_repository_name  = "advanced-web-app-repo"

  # Build configuration
  build_timeout = 120
  build_compute_type = "BUILD_GENERAL1_MEDIUM"
  build_privileged_mode = true
  buildspec_file = "buildspec.yml"
  
  build_environment_variables = [
    {
      key   = "NODE_ENV"
      value = "production"
    },
    {
      key   = "BUILD_VERSION"
      value = "1.0.0"
    },
    {
      key   = "AWS_DEFAULT_REGION"
      value = "us-east-1"
    }
  ]

  # Deployment configuration
  deploy_enabled = true
  deploy_compute_platform = "Server"
  deployment_config_name = "CodeDeployDefault.OneAtATime"
  
  deploy_ec2_tag_sets = [
    [
      {
        key   = "Environment"
        type  = "KEY_AND_VALUE"
        value = "prod"
      },
      {
        key   = "Application"
        type  = "KEY_AND_VALUE"
        value = "advanced-web-app"
      }
    ]
  ]

  auto_rollback_enabled = true
  auto_rollback_events = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]

  # CloudFormation configuration
  cloudformation_deploy_enabled = true
  create_cloudformation_stack = true
  cloudformation_template_body = data.template_file.cloudformation_template.rendered
  cloudformation_template_path = "template.yaml"
  cloudformation_capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]

  cloudformation_parameters = [
    {
      key   = "Environment"
      value = "prod"
    },
    {
      key   = "ProjectName"
      value = "advanced-web-app"
    }
  ]

  # Monitoring and notifications
  enable_notifications = true
  notification_emails = ["devops@company.com", "alerts@company.com"]
  enable_pipeline_monitoring = true
  enable_pipeline_triggers = true

  # Logging and retention
  log_retention_days = 30
  artifact_retention_days = 90

  # Common tags
  common_tags = {
    Environment = "prod"
    Project     = "advanced-web-app"
    Owner       = "devops-team"
    ManagedBy   = "terraform"
    CostCenter  = "engineering"
    Application = "web-app"
  }
}

# ==============================================================================
# Data Sources
# ==============================================================================

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# ==============================================================================
# CloudFormation Template
# ==============================================================================

data "template_file" "cloudformation_template" {
  template = file("${path.module}/templates/infrastructure.yaml")

  vars = {
    environment  = "prod"
    project_name = "advanced-web-app"
    region       = data.aws_region.current.name
    account_id   = data.aws_caller_identity.current.account_id
  }
}

# ==============================================================================
# Additional Resources
# ==============================================================================

# Example: Create a CloudWatch Dashboard for monitoring
resource "aws_cloudwatch_dashboard" "pipeline_dashboard" {
  dashboard_name = "advanced-web-app-pipeline-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/CodePipeline", "FailedExecutions", "PipelineName", module.advanced_pipeline.codepipeline_name],
            [".", "SucceededExecutions", ".", "."]
          ]
          period = 300
          stat   = "Sum"
          region = data.aws_region.current.name
          title  = "Pipeline Executions"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/CodeBuild", "FailedBuilds", "ProjectName", module.advanced_pipeline.codebuild_project_name],
            [".", "SucceededBuilds", ".", "."]
          ]
          period = 300
          stat   = "Sum"
          region = data.aws_region.current.name
          title  = "Build Results"
        }
      }
    ]
  })
}

# ==============================================================================
# Outputs
# ==============================================================================

output "pipeline_name" {
  description = "Name of the created CodePipeline"
  value       = module.advanced_pipeline.codepipeline_name
}

output "repository_name" {
  description = "Name of the created CodeCommit repository"
  value       = module.advanced_pipeline.codecommit_repository_name
}

output "repository_clone_url_http" {
  description = "HTTP clone URL for the CodeCommit repository"
  value       = module.advanced_pipeline.codecommit_clone_url_http
}

output "artifacts_bucket" {
  description = "Name of the S3 bucket for artifacts"
  value       = module.advanced_pipeline.artifacts_bucket_name
}

output "cloudformation_stack_name" {
  description = "Name of the CloudFormation stack"
  value       = module.advanced_pipeline.cloudformation_stack_name
}

output "pipeline_url" {
  description = "URL to view the pipeline in AWS Console"
  value       = module.advanced_pipeline.pipeline_url
}

output "dashboard_url" {
  description = "URL to view the CloudWatch dashboard"
  value       = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.pipeline_dashboard.dashboard_name}"
} 