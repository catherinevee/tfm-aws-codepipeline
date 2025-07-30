# ==============================================================================
# AWS CodePipeline CI/CD Module
# ==============================================================================

# ==============================================================================
# Data Sources
# ==============================================================================

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

# ==============================================================================
# S3 Bucket for Artifacts
# ==============================================================================

resource "aws_s3_bucket" "artifacts" {
  bucket = var.artifacts_bucket_name

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-artifacts"
    Purpose = "CodePipeline Artifacts"
  })
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    id     = "cleanup_old_artifacts"
    status = "Enabled"

    expiration {
      days = var.artifact_retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

# ==============================================================================
# IAM Roles and Policies
# ==============================================================================

# CodePipeline Service Role
resource "aws_iam_role" "codepipeline" {
  name = "${var.project_name}-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy" "codepipeline" {
  name = "${var.project_name}-codepipeline-policy"
  role = aws_iam_role.codepipeline.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.artifacts.arn,
          "${aws_s3_bucket.artifacts.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codecommit:CancelUploadArchive",
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:UploadArchive"
        ]
        Resource = aws_codecommit_repository.main.arn
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "codedeploy:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudformation:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = "*"
      }
    ]
  })
}

# CodeBuild Service Role
resource "aws_iam_role" "codebuild" {
  name = "${var.project_name}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy" "codebuild" {
  name = "${var.project_name}-codebuild-policy"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.artifacts.arn,
          "${aws_s3_bucket.artifacts.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codecommit:GitPull"
        ]
        Resource = aws_codecommit_repository.main.arn
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

# CodeDeploy Service Role
resource "aws_iam_role" "codedeploy" {
  name = "${var.project_name}-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "codedeploy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.codedeploy.name
}

# ==============================================================================
# CodeCommit Repository
# ==============================================================================

resource "aws_codecommit_repository" "main" {
  repository_name = var.codecommit_repository_name
  description     = "Source code repository for ${var.project_name}"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-repository"
  })
}

# ==============================================================================
# CodeBuild Project
# ==============================================================================

resource "aws_codebuild_project" "main" {
  name          = "${var.project_name}-build"
  description   = "Build project for ${var.project_name}"
  build_timeout = var.build_timeout
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = var.build_compute_type
    image                       = var.build_image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = var.build_privileged_mode

    environment_variable {
      name  = "PROJECT_NAME"
      value = var.project_name
    }

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
    }

    dynamic "environment_variable" {
      for_each = var.build_environment_variables
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = var.buildspec_file
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/${var.project_name}"
      stream_name = "build-log"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.artifacts.id}/build-logs"
    }
  }

  tags = var.common_tags
}

# ==============================================================================
# CodeDeploy Application and Deployment Group
# ==============================================================================

resource "aws_codedeploy_app" "main" {
  compute_platform = var.deploy_compute_platform
  name             = "${var.project_name}-deploy"

  tags = var.common_tags
}

resource "aws_codedeploy_deployment_group" "main" {
  app_name               = aws_codedeploy_app.main.name
  deployment_group_name  = "${var.project_name}-deployment-group"
  service_role_arn       = aws_iam_role.codedeploy.arn
  deployment_config_name = var.deployment_config_name

  dynamic "ec2_tag_set" {
    for_each = var.deploy_ec2_tag_sets
    content {
      dynamic "ec2_tag_filter" {
        for_each = ec2_tag_set.value
        content {
          key   = ec2_tag_filter.key
          type  = ec2_tag_filter.type
          value = ec2_tag_filter.value
        }
      }
    }
  }

  auto_rollback_configuration {
    enabled = var.auto_rollback_enabled
    events  = var.auto_rollback_events
  }

  alarm_configuration {
    enabled                   = var.alarm_configuration_enabled
    ignore_poll_alarm_failure = var.ignore_poll_alarm_failure

    dynamic "alarms" {
      for_each = var.alarm_names
      content {
        name = alarms.value
      }
    }
  }

  tags = var.common_tags
}

# ==============================================================================
# CloudFormation Stack
# ==============================================================================

resource "aws_cloudformation_stack" "main" {
  count = var.create_cloudformation_stack ? 1 : 0

  name          = "${var.project_name}-stack"
  template_body = var.cloudformation_template_body
  capabilities  = var.cloudformation_capabilities

  dynamic "parameters" {
    for_each = var.cloudformation_parameters
    content {
      parameter_key   = parameters.key
      parameter_value = parameters.value
    }
  }

  tags = var.common_tags
}

# ==============================================================================
# CodePipeline
# ==============================================================================

resource "aws_codepipeline" "main" {
  name     = "${var.project_name}-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"

    encryption_key {
      id   = aws_s3_bucket.artifacts.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = aws_codecommit_repository.main.repository_name
        BranchName     = var.source_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.main.name
      }
    }
  }

  dynamic "stage" {
    for_each = var.deploy_enabled ? [1] : []
    content {
      name = "Deploy"

      action {
        name            = "Deploy"
        category        = "Deploy"
        owner           = "AWS"
        provider        = "CodeDeploy"
        region          = data.aws_region.current.name
        input_artifacts = ["source_output"]
        version         = "1"

        configuration = {
          ApplicationName     = aws_codedeploy_app.main.name
          DeploymentGroupName = aws_codedeploy_deployment_group.main.deployment_group_name
        }
      }
    }
  }

  dynamic "stage" {
    for_each = var.cloudformation_deploy_enabled ? [1] : []
    content {
      name = "CloudFormation"

      action {
        name            = "Deploy"
        category        = "Deploy"
        owner           = "AWS"
        provider        = "CloudFormation"
        region          = data.aws_region.current.name
        input_artifacts = ["source_output"]
        version         = "1"

        configuration = {
          ActionMode     = "CREATE_UPDATE"
          StackName      = var.create_cloudformation_stack ? aws_cloudformation_stack.main[0].name : var.cloudformation_stack_name
          TemplatePath   = "source_output::${var.cloudformation_template_path}"
          RoleArn        = aws_iam_role.codepipeline.arn
          Capabilities   = join(",", var.cloudformation_capabilities)
        }
      }
    }
  }

  tags = var.common_tags
}

# ==============================================================================
# CloudWatch Log Groups
# ==============================================================================

resource "aws_cloudwatch_log_group" "codepipeline" {
  name              = "/aws/codepipeline/${var.project_name}"
  retention_in_days = var.log_retention_days

  tags = var.common_tags
}

resource "aws_cloudwatch_log_group" "codebuild" {
  name              = "/aws/codebuild/${var.project_name}"
  retention_in_days = var.log_retention_days

  tags = var.common_tags
}

# ==============================================================================
# EventBridge Rule for Pipeline Triggers
# ==============================================================================

resource "aws_cloudwatch_event_rule" "codepipeline_trigger" {
  count = var.enable_pipeline_triggers ? 1 : 0

  name        = "${var.project_name}-pipeline-trigger"
  description = "Trigger CodePipeline on CodeCommit changes"

  event_pattern = jsonencode({
    source      = ["aws.codecommit"]
    detail-type = ["CodeCommit Repository State Change"]
    detail = {
      repositoryName = [aws_codecommit_repository.main.repository_name]
      event          = ["referenceCreated", "referenceUpdated"]
      referenceName  = ["refs/heads/${var.source_branch}"]
    }
  })

  tags = var.common_tags
}

resource "aws_cloudwatch_event_target" "codepipeline" {
  count = var.enable_pipeline_triggers ? 1 : 0

  rule      = aws_cloudwatch_event_rule.codepipeline_trigger[0].name
  target_id = "CodePipelineTarget"
  arn       = aws_codepipeline.main.arn
  role_arn  = aws_iam_role.codepipeline.arn
}

# ==============================================================================
# SNS Topic for Notifications
# ==============================================================================

resource "aws_sns_topic" "pipeline_notifications" {
  count = var.enable_notifications ? 1 : 0

  name = "${var.project_name}-pipeline-notifications"

  tags = var.common_tags
}

resource "aws_sns_topic_subscription" "email" {
  count = var.enable_notifications ? length(var.notification_emails) : 0

  topic_arn = aws_sns_topic.pipeline_notifications[0].arn
  protocol  = "email"
  endpoint  = var.notification_emails[count.index]
}

# ==============================================================================
# CloudWatch Alarms
# ==============================================================================

resource "aws_cloudwatch_metric_alarm" "pipeline_failures" {
  count = var.enable_pipeline_monitoring ? 1 : 0

  alarm_name          = "${var.project_name}-pipeline-failures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FailedExecutions"
  namespace           = "AWS/CodePipeline"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors pipeline failures"
  alarm_actions       = var.enable_notifications ? [aws_sns_topic.pipeline_notifications[0].arn] : []

  dimensions = {
    PipelineName = aws_codepipeline.main.name
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "build_failures" {
  count = var.enable_pipeline_monitoring ? 1 : 0

  alarm_name          = "${var.project_name}-build-failures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FailedBuilds"
  namespace           = "AWS/CodeBuild"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors build failures"
  alarm_actions       = var.enable_notifications ? [aws_sns_topic.pipeline_notifications[0].arn] : []

  dimensions = {
    ProjectName = aws_codebuild_project.main.name
  }

  tags = var.common_tags
} 