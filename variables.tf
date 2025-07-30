# ==============================================================================
# Variables for AWS CodePipeline CI/CD Module
# ==============================================================================

# ==============================================================================
# Required Variables
# ==============================================================================

variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.project_name))
    error_message = "Project name must contain only alphanumeric characters and hyphens."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod", "test"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, test."
  }
}

variable "artifacts_bucket_name" {
  description = "Name of the S3 bucket for storing pipeline artifacts"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.artifacts_bucket_name))
    error_message = "Bucket name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "codecommit_repository_name" {
  description = "Name of the CodeCommit repository"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]+$", var.codecommit_repository_name))
    error_message = "Repository name must contain only alphanumeric characters, dots, underscores, and hyphens."
  }
}

# ==============================================================================
# Optional Variables with Defaults
# ==============================================================================

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.common_tags : can(regex("^[a-zA-Z0-9_.:/=+-@]+$", k)) && can(regex("^[a-zA-Z0-9_.:/=+-@]*$", v))])
    error_message = "Tags must contain only alphanumeric characters, dots, underscores, colons, slashes, equals, plus, minus, and at signs."
  }
}

variable "source_branch" {
  description = "Source branch for the pipeline"
  type        = string
  default     = "main"
}

variable "buildspec_file" {
  description = "Path to the buildspec file in the repository"
  type        = string
  default     = "buildspec.yml"
}

variable "build_timeout" {
  description = "Build timeout in minutes"
  type        = number
  default     = 60

  validation {
    condition     = var.build_timeout >= 5 && var.build_timeout <= 480
    error_message = "Build timeout must be between 5 and 480 minutes."
  }
}

variable "build_compute_type" {
  description = "CodeBuild compute type"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"

  validation {
    condition     = contains(["BUILD_GENERAL1_SMALL", "BUILD_GENERAL1_MEDIUM", "BUILD_GENERAL1_LARGE", "BUILD_GENERAL1_2XLARGE"], var.build_compute_type)
    error_message = "Build compute type must be one of: BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM, BUILD_GENERAL1_LARGE, BUILD_GENERAL1_2XLARGE."
  }
}

variable "build_image" {
  description = "CodeBuild image to use"
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
}

variable "build_privileged_mode" {
  description = "Enable privileged mode for CodeBuild"
  type        = bool
  default     = false
}

variable "build_environment_variables" {
  description = "Environment variables for CodeBuild"
  type = list(object({
    key   = string
    value = string
  }))
  default = []
}

variable "deploy_enabled" {
  description = "Enable CodeDeploy deployment stage"
  type        = bool
  default     = true
}

variable "deploy_compute_platform" {
  description = "CodeDeploy compute platform"
  type        = string
  default     = "Server"

  validation {
    condition     = contains(["Server", "Lambda", "ECS"], var.deploy_compute_platform)
    error_message = "Deploy compute platform must be one of: Server, Lambda, ECS."
  }
}

variable "deployment_config_name" {
  description = "CodeDeploy deployment configuration name"
  type        = string
  default     = "CodeDeployDefault.OneAtATime"
}

variable "deploy_ec2_tag_sets" {
  description = "EC2 tag sets for CodeDeploy deployment group"
  type = list(list(object({
    key   = string
    type  = string
    value = string
  })))
  default = []
}

variable "auto_rollback_enabled" {
  description = "Enable auto rollback for CodeDeploy"
  type        = bool
  default     = true
}

variable "auto_rollback_events" {
  description = "Events that trigger auto rollback"
  type        = list(string)
  default     = ["DEPLOYMENT_FAILURE"]

  validation {
    condition     = alltrue([for event in var.auto_rollback_events : contains(["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM", "DEPLOYMENT_STOP_ON_INSTANCE_FAILURE"], event)])
    error_message = "Auto rollback events must be one of: DEPLOYMENT_FAILURE, DEPLOYMENT_STOP_ON_ALARM, DEPLOYMENT_STOP_ON_INSTANCE_FAILURE."
  }
}

variable "alarm_configuration_enabled" {
  description = "Enable alarm configuration for CodeDeploy"
  type        = bool
  default     = false
}

variable "ignore_poll_alarm_failure" {
  description = "Ignore poll alarm failure for CodeDeploy"
  type        = bool
  default     = false
}

variable "alarm_names" {
  description = "CloudWatch alarm names for CodeDeploy"
  type        = list(string)
  default     = []
}

variable "cloudformation_deploy_enabled" {
  description = "Enable CloudFormation deployment stage"
  type        = bool
  default     = false
}

variable "create_cloudformation_stack" {
  description = "Create a new CloudFormation stack"
  type        = bool
  default     = false
}

variable "cloudformation_stack_name" {
  description = "Name of existing CloudFormation stack to update"
  type        = string
  default     = ""
}

variable "cloudformation_template_body" {
  description = "CloudFormation template body"
  type        = string
  default     = ""
}

variable "cloudformation_template_path" {
  description = "Path to CloudFormation template in source artifacts"
  type        = string
  default     = "template.yaml"
}

variable "cloudformation_capabilities" {
  description = "CloudFormation capabilities"
  type        = list(string)
  default     = ["CAPABILITY_IAM"]

  validation {
    condition     = alltrue([for cap in var.cloudformation_capabilities : contains(["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"], cap)])
    error_message = "CloudFormation capabilities must be one of: CAPABILITY_IAM, CAPABILITY_NAMED_IAM, CAPABILITY_AUTO_EXPAND."
  }
}

variable "cloudformation_parameters" {
  description = "CloudFormation parameters"
  type = list(object({
    key   = string
    value = string
  }))
  default = []
}

variable "artifact_retention_days" {
  description = "Number of days to retain artifacts in S3"
  type        = number
  default     = 30

  validation {
    condition     = var.artifact_retention_days >= 1 && var.artifact_retention_days <= 3650
    error_message = "Artifact retention days must be between 1 and 3650."
  }
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 14

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention days must be one of the allowed values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653."
  }
}

variable "enable_pipeline_triggers" {
  description = "Enable automatic pipeline triggers on CodeCommit changes"
  type        = bool
  default     = true
}

variable "enable_notifications" {
  description = "Enable SNS notifications for pipeline events"
  type        = bool
  default     = false
}

variable "notification_emails" {
  description = "Email addresses for pipeline notifications"
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for email in var.notification_emails : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))])
    error_message = "Notification emails must be valid email addresses."
  }
}

variable "enable_pipeline_monitoring" {
  description = "Enable CloudWatch alarms for pipeline monitoring"
  type        = bool
  default     = true
} 