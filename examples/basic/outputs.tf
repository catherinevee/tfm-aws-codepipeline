# ==============================================================================
# Outputs for Basic Example
# ==============================================================================

output "module_summary" {
  description = "Summary of all resources created by the basic pipeline module"
  value       = module.basic_pipeline.module_summary
}

output "all_outputs" {
  description = "All outputs from the basic pipeline module"
  value = {
    # S3 Artifacts
    artifacts_bucket_name   = module.basic_pipeline.artifacts_bucket_name
    artifacts_bucket_arn    = module.basic_pipeline.artifacts_bucket_arn
    artifacts_bucket_region = module.basic_pipeline.artifacts_bucket_region

    # CodeCommit Repository
    codecommit_repository_name = module.basic_pipeline.codecommit_repository_name
    codecommit_repository_id   = module.basic_pipeline.codecommit_repository_id
    codecommit_repository_arn  = module.basic_pipeline.codecommit_repository_arn
    codecommit_clone_url_http  = module.basic_pipeline.codecommit_clone_url_http
    codecommit_clone_url_ssh   = module.basic_pipeline.codecommit_clone_url_ssh

    # CodeBuild Project
    codebuild_project_name = module.basic_pipeline.codebuild_project_name
    codebuild_project_arn  = module.basic_pipeline.codebuild_project_arn

    # CodeDeploy Application
    codedeploy_app_name                = module.basic_pipeline.codedeploy_app_name
    codedeploy_app_arn                 = module.basic_pipeline.codedeploy_app_arn
    codedeploy_deployment_group_name   = module.basic_pipeline.codedeploy_deployment_group_name
    codedeploy_deployment_group_arn    = module.basic_pipeline.codedeploy_deployment_group_arn

    # CodePipeline
    codepipeline_name = module.basic_pipeline.codepipeline_name
    codepipeline_arn  = module.basic_pipeline.codepipeline_arn
    codepipeline_id   = module.basic_pipeline.codepipeline_id

    # IAM Roles
    codepipeline_role_arn = module.basic_pipeline.codepipeline_role_arn
    codepipeline_role_name = module.basic_pipeline.codepipeline_role_name
    codebuild_role_arn     = module.basic_pipeline.codebuild_role_arn
    codebuild_role_name    = module.basic_pipeline.codebuild_role_name
    codedeploy_role_arn    = module.basic_pipeline.codedeploy_role_arn
    codedeploy_role_name   = module.basic_pipeline.codedeploy_role_name

    # CloudWatch Log Groups
    codepipeline_log_group_name = module.basic_pipeline.codepipeline_log_group_name
    codebuild_log_group_name    = module.basic_pipeline.codebuild_log_group_name

    # EventBridge Rules
    pipeline_trigger_rule_name = module.basic_pipeline.pipeline_trigger_rule_name
    pipeline_trigger_rule_arn  = module.basic_pipeline.pipeline_trigger_rule_arn

    # CloudWatch Alarms
    pipeline_failures_alarm_name = module.basic_pipeline.pipeline_failures_alarm_name
    pipeline_failures_alarm_arn  = module.basic_pipeline.pipeline_failures_alarm_arn
    build_failures_alarm_name    = module.basic_pipeline.build_failures_alarm_name
    build_failures_alarm_arn     = module.basic_pipeline.build_failures_alarm_arn

    # Console URLs
    pipeline_url   = module.basic_pipeline.pipeline_url
    codecommit_url = module.basic_pipeline.codecommit_url
    codebuild_url  = module.basic_pipeline.codebuild_url
    codedeploy_url = module.basic_pipeline.codedeploy_url
  }
} 