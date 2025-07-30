# ==============================================================================
# Outputs for AWS CodePipeline CI/CD Module
# ==============================================================================

# ==============================================================================
# S3 Artifacts Bucket
# ==============================================================================

output "artifacts_bucket_name" {
  description = "Name of the S3 bucket used for artifacts"
  value       = aws_s3_bucket.artifacts.bucket
}

output "artifacts_bucket_arn" {
  description = "ARN of the S3 bucket used for artifacts"
  value       = aws_s3_bucket.artifacts.arn
}

output "artifacts_bucket_region" {
  description = "Region of the S3 bucket used for artifacts"
  value       = aws_s3_bucket.artifacts.region
}

# ==============================================================================
# CodeCommit Repository
# ==============================================================================

output "codecommit_repository_name" {
  description = "Name of the CodeCommit repository"
  value       = aws_codecommit_repository.main.repository_name
}

output "codecommit_repository_id" {
  description = "ID of the CodeCommit repository"
  value       = aws_codecommit_repository.main.repository_id
}

output "codecommit_repository_arn" {
  description = "ARN of the CodeCommit repository"
  value       = aws_codecommit_repository.main.arn
}

output "codecommit_clone_url_http" {
  description = "HTTP clone URL for the CodeCommit repository"
  value       = aws_codecommit_repository.main.clone_url_http
}

output "codecommit_clone_url_ssh" {
  description = "SSH clone URL for the CodeCommit repository"
  value       = aws_codecommit_repository.main.clone_url_ssh
}

# ==============================================================================
# CodeBuild Project
# ==============================================================================

output "codebuild_project_name" {
  description = "Name of the CodeBuild project"
  value       = aws_codebuild_project.main.name
}

output "codebuild_project_arn" {
  description = "ARN of the CodeBuild project"
  value       = aws_codebuild_project.main.arn
}

# ==============================================================================
# CodeDeploy Application
# ==============================================================================

output "codedeploy_app_name" {
  description = "Name of the CodeDeploy application"
  value       = aws_codedeploy_app.main.name
}

output "codedeploy_app_arn" {
  description = "ARN of the CodeDeploy application"
  value       = aws_codedeploy_app.main.arn
}

output "codedeploy_deployment_group_name" {
  description = "Name of the CodeDeploy deployment group"
  value       = aws_codedeploy_deployment_group.main.deployment_group_name
}

output "codedeploy_deployment_group_arn" {
  description = "ARN of the CodeDeploy deployment group"
  value       = aws_codedeploy_deployment_group.main.arn
}

# ==============================================================================
# CodePipeline
# ==============================================================================

output "codepipeline_name" {
  description = "Name of the CodePipeline"
  value       = aws_codepipeline.main.name
}

output "codepipeline_arn" {
  description = "ARN of the CodePipeline"
  value       = aws_codepipeline.main.arn
}

output "codepipeline_id" {
  description = "ID of the CodePipeline"
  value       = aws_codepipeline.main.id
}

# ==============================================================================
# CloudFormation Stack
# ==============================================================================

output "cloudformation_stack_name" {
  description = "Name of the CloudFormation stack"
  value       = var.create_cloudformation_stack ? aws_cloudformation_stack.main[0].name : var.cloudformation_stack_name
}

output "cloudformation_stack_id" {
  description = "ID of the CloudFormation stack"
  value       = var.create_cloudformation_stack ? aws_cloudformation_stack.main[0].id : null
}

# ==============================================================================
# IAM Roles
# ==============================================================================

output "codepipeline_role_arn" {
  description = "ARN of the CodePipeline IAM role"
  value       = aws_iam_role.codepipeline.arn
}

output "codepipeline_role_name" {
  description = "Name of the CodePipeline IAM role"
  value       = aws_iam_role.codepipeline.name
}

output "codebuild_role_arn" {
  description = "ARN of the CodeBuild IAM role"
  value       = aws_iam_role.codebuild.arn
}

output "codebuild_role_name" {
  description = "Name of the CodeBuild IAM role"
  value       = aws_iam_role.codebuild.name
}

output "codedeploy_role_arn" {
  description = "ARN of the CodeDeploy IAM role"
  value       = aws_iam_role.codedeploy.arn
}

output "codedeploy_role_name" {
  description = "Name of the CodeDeploy IAM role"
  value       = aws_iam_role.codedeploy.name
}

# ==============================================================================
# CloudWatch Log Groups
# ==============================================================================

output "codepipeline_log_group_name" {
  description = "Name of the CodePipeline CloudWatch log group"
  value       = aws_cloudwatch_log_group.codepipeline.name
}

output "codebuild_log_group_name" {
  description = "Name of the CodeBuild CloudWatch log group"
  value       = aws_cloudwatch_log_group.codebuild.name
}

# ==============================================================================
# EventBridge Rules
# ==============================================================================

output "pipeline_trigger_rule_name" {
  description = "Name of the EventBridge rule for pipeline triggers"
  value       = var.enable_pipeline_triggers ? aws_cloudwatch_event_rule.codepipeline_trigger[0].name : null
}

output "pipeline_trigger_rule_arn" {
  description = "ARN of the EventBridge rule for pipeline triggers"
  value       = var.enable_pipeline_triggers ? aws_cloudwatch_event_rule.codepipeline_trigger[0].arn : null
}

# ==============================================================================
# SNS Topics
# ==============================================================================

output "pipeline_notifications_topic_arn" {
  description = "ARN of the SNS topic for pipeline notifications"
  value       = var.enable_notifications ? aws_sns_topic.pipeline_notifications[0].arn : null
}

output "pipeline_notifications_topic_name" {
  description = "Name of the SNS topic for pipeline notifications"
  value       = var.enable_notifications ? aws_sns_topic.pipeline_notifications[0].name : null
}

# ==============================================================================
# CloudWatch Alarms
# ==============================================================================

output "pipeline_failures_alarm_name" {
  description = "Name of the CloudWatch alarm for pipeline failures"
  value       = var.enable_pipeline_monitoring ? aws_cloudwatch_metric_alarm.pipeline_failures[0].alarm_name : null
}

output "pipeline_failures_alarm_arn" {
  description = "ARN of the CloudWatch alarm for pipeline failures"
  value       = var.enable_pipeline_monitoring ? aws_cloudwatch_metric_alarm.pipeline_failures[0].arn : null
}

output "build_failures_alarm_name" {
  description = "Name of the CloudWatch alarm for build failures"
  value       = var.enable_pipeline_monitoring ? aws_cloudwatch_metric_alarm.build_failures[0].alarm_name : null
}

output "build_failures_alarm_arn" {
  description = "ARN of the CloudWatch alarm for build failures"
  value       = var.enable_pipeline_monitoring ? aws_cloudwatch_metric_alarm.build_failures[0].arn : null
}

# ==============================================================================
# Summary Information
# ==============================================================================

output "pipeline_url" {
  description = "URL to view the CodePipeline in the AWS Console"
  value       = "https://${data.aws_region.current.name}.console.aws.amazon.com/codesuite/codepipeline/pipelines/${aws_codepipeline.main.name}/view"
}

output "codecommit_url" {
  description = "URL to view the CodeCommit repository in the AWS Console"
  value       = "https://${data.aws_region.current.name}.console.aws.amazon.com/codesuite/codecommit/repositories/${aws_codecommit_repository.main.repository_name}/browse"
}

output "codebuild_url" {
  description = "URL to view the CodeBuild project in the AWS Console"
  value       = "https://${data.aws_region.current.name}.console.aws.amazon.com/codesuite/codebuild/projects/${aws_codebuild_project.main.name}/history"
}

output "codedeploy_url" {
  description = "URL to view the CodeDeploy application in the AWS Console"
  value       = "https://${data.aws_region.current.name}.console.aws.amazon.com/codesuite/codedeploy/applications/${aws_codedeploy_app.main.name}"
}

output "module_summary" {
  description = "Summary of all resources created by this module"
  value = {
    project_name                    = var.project_name
    environment                     = var.environment
    artifacts_bucket                = aws_s3_bucket.artifacts.bucket
    codecommit_repository           = aws_codecommit_repository.main.repository_name
    codebuild_project               = aws_codebuild_project.main.name
    codedeploy_application          = aws_codedeploy_app.main.name
    codepipeline                    = aws_codepipeline.main.name
    cloudformation_stack            = var.create_cloudformation_stack ? aws_cloudformation_stack.main[0].name : var.cloudformation_stack_name
    deploy_enabled                  = var.deploy_enabled
    cloudformation_deploy_enabled   = var.cloudformation_deploy_enabled
    enable_notifications            = var.enable_notifications
    enable_pipeline_monitoring      = var.enable_pipeline_monitoring
    enable_pipeline_triggers        = var.enable_pipeline_triggers
    region                          = data.aws_region.current.name
    account_id                      = data.aws_caller_identity.current.account_id
  }
} 