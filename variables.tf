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

# ==============================================================================
# Enhanced CodePipeline Configuration Variables
# ==============================================================================

variable "codepipelines" {
  description = "Map of CodePipelines to create"
  type = map(object({
    name = string
    role_arn = optional(string, null)
    artifact_store = object({
      location = string
      type = optional(string, "S3")
      encryption_key = optional(object({
        id = string
        type = string
      }), {})
    })
    stages = list(object({
      name = string
      actions = list(object({
        name = string
        category = string
        owner = string
        provider = string
        version = optional(string, "1")
        region = optional(string, null)
        role_arn = optional(string, null)
        run_order = optional(number, 1)
        configuration = optional(map(string), {})
        input_artifacts = optional(list(string), [])
        output_artifacts = optional(list(string), [])
        namespace = optional(string, null)
        region = optional(string, null)
        role_arn = optional(string, null)
        run_order = optional(number, 1)
        configuration = optional(map(string), {})
        input_artifacts = optional(list(string), [])
        output_artifacts = optional(list(string), [])
        namespace = optional(string, null)
      }))
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "codepipeline_webhooks" {
  description = "Map of CodePipeline webhooks to create"
  type = map(object({
    name = string
    authentication_configuration = object({
      allowed_ip_range = optional(string, null)
      secret_token = optional(string, null)
    })
    filter = list(object({
      json_path = string
      match_equals = string
    }))
    target_action = string
    target_pipeline = string
    url = optional(string, null)
  }))
  default = {}
}

# ==============================================================================
# Enhanced CodeBuild Configuration Variables
# ==============================================================================

variable "codebuild_projects" {
  description = "Map of CodeBuild projects to create"
  type = map(object({
    name = string
    description = optional(string, null)
    build_timeout = optional(number, 60)
    queued_timeout = optional(number, 480)
    service_role = string
    
    # Artifacts
    artifacts = object({
      type = string
      location = optional(string, null)
      path = optional(string, null)
      namespace_type = optional(string, null)
      name = optional(string, null)
      packaging = optional(string, null)
      override_artifact_name = optional(bool, null)
      encryption_disabled = optional(bool, null)
      artifact_identifier = optional(string, null)
      bucket_owner_access = optional(string, null)
    })
    
    # Cache
    cache = optional(object({
      type = optional(string, "NO_CACHE")
      location = optional(string, null)
      modes = optional(list(string), [])
    }), {})
    
    # Environment
    environment = object({
      compute_type = string
      image = string
      type = string
      image_pull_credentials_type = optional(string, "CODEBUILD")
      privileged_mode = optional(bool, null)
      certificate = optional(string, null)
      registry_credential = optional(object({
        credential = string
        credential_provider = string
      }), {})
      environment_variables = optional(list(object({
        name = string
        value = string
        type = optional(string, "PLAINTEXT")
      })), [])
    })
    
    # Source
    source = object({
      type = string
      location = optional(string, null)
      git_clone_depth = optional(number, null)
      git_submodules_config = optional(object({
        fetch_submodules = bool
      }), {})
      buildspec = optional(string, null)
      auth = optional(object({
        type = string
        resource = optional(string, null)
      }), {})
      report_build_status = optional(bool, null)
      insecure_ssl = optional(bool, null)
    })
    
    # VPC configuration
    vpc_config = optional(object({
      vpc_id = string
      subnets = list(string)
      security_group_ids = list(string)
    }), {})
    
    # Logs
    logs_config = optional(object({
      cloudwatch_logs = optional(object({
        group_name = optional(string, null)
        stream_name = optional(string, null)
        status = optional(string, "ENABLED")
      }), {})
      s3_logs = optional(object({
        status = optional(string, "DISABLED")
        location = optional(string, null)
        encryption_disabled = optional(bool, null)
      }), {})
    }), {})
    
    # Secondary artifacts
    secondary_artifacts = optional(list(object({
      artifact_identifier = string
      type = string
      location = optional(string, null)
      path = optional(string, null)
      namespace_type = optional(string, null)
      name = optional(string, null)
      packaging = optional(string, null)
      override_artifact_name = optional(bool, null)
      encryption_disabled = optional(bool, null)
      bucket_owner_access = optional(string, null)
    })), [])
    
    # Secondary sources
    secondary_sources = optional(list(object({
      source_identifier = string
      type = string
      location = optional(string, null)
      git_clone_depth = optional(number, null)
      git_submodules_config = optional(object({
        fetch_submodules = bool
      }), {})
      buildspec = optional(string, null)
      auth = optional(object({
        type = string
        resource = optional(string, null)
      }), {})
      report_build_status = optional(bool, null)
      insecure_ssl = optional(bool, null)
    })), [])
    
    # File system locations
    file_system_locations = optional(list(object({
      type = string
      location = optional(string, null)
      mount_point = optional(string, null)
      identifier = optional(string, null)
      mount_options = optional(string, null)
    })), [])
    
    # Tags
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "codebuild_source_credentials" {
  description = "Map of CodeBuild source credentials to create"
  type = map(object({
    auth_type = string
    server_type = string
    token = string
    user_name = optional(string, null)
  }))
  default = {}
}

variable "codebuild_report_groups" {
  description = "Map of CodeBuild report groups to create"
  type = map(object({
    name = string
    type = string
    export_config = object({
      type = string
      s3_destination = optional(object({
        bucket = string
        encryption_key = optional(string, null)
        packaging = optional(string, null)
        path = optional(string, null)
      }), {})
    })
    delete_reports = optional(bool, false)
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced CodeDeploy Configuration Variables
# ==============================================================================

variable "codedeploy_applications" {
  description = "Map of CodeDeploy applications to create"
  type = map(object({
    name = string
    compute_platform = optional(string, "Server")
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "codedeploy_deployment_groups" {
  description = "Map of CodeDeploy deployment groups to create"
  type = map(object({
    app_name = string
    deployment_group_name = string
    service_role_arn = string
    deployment_style = optional(object({
      deployment_option = optional(string, "WITH_TRAFFIC_CONTROL")
      deployment_type = optional(string, "IN_PLACE")
    }), {})
    ec2_tag_set = optional(list(object({
      ec2_tag_filter = list(object({
        key = optional(string, null)
        type = optional(string, null)
        value = optional(string, null)
      }))
    })), [])
    ecs_service = optional(object({
      cluster_name = string
      service_name = string
    }), {})
    load_balancer_info = optional(object({
      elb_info = optional(list(object({
        name = optional(string, null)
      })), [])
      target_group_info = optional(list(object({
        name = optional(string, null)
      })), [])
      target_group_pair_info = optional(object({
        prod_traffic_route = object({
          listener_arns = list(string)
        })
        target_groups = list(object({
          name = string
        }))
        test_traffic_route = optional(object({
          listener_arns = list(string)
        }), {})
      }), {})
    }), {})
    on_premises_instance_tag_set = optional(list(object({
      on_premises_tag_filter = list(object({
        key = optional(string, null)
        type = optional(string, null)
        value = optional(string, null)
      }))
    })), [])
    trigger_configuration = optional(list(object({
      trigger_events = list(string)
      trigger_name = string
      trigger_target_arn = string
    })), [])
    auto_rollback_configuration = optional(object({
      enabled = optional(bool, null)
      events = optional(list(string), [])
    }), {})
    alarm_configuration = optional(object({
      alarms = optional(list(string), [])
      enabled = optional(bool, null)
      ignore_poll_alarm_failure = optional(bool, null)
    }), {})
    auto_scaling_groups = optional(list(string), [])
    deployment_config_name = optional(string, null)
    ec2_tag_set = optional(list(object({
      ec2_tag_filter = list(object({
        key = optional(string, null)
        type = optional(string, null)
        value = optional(string, null)
      }))
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "codedeploy_deployment_configs" {
  description = "Map of CodeDeploy deployment configurations to create"
  type = map(object({
    deployment_config_name = string
    compute_platform = optional(string, "Server")
    minimum_healthy_hosts = optional(object({
      type = optional(string, null)
      value = optional(number, null)
    }), {})
    traffic_routing_config = optional(object({
      type = optional(string, null)
      time_based_canary = optional(object({
        interval = optional(number, null)
        percentage = optional(number, null)
      }), {})
      time_based_linear = optional(object({
        interval = optional(number, null)
        percentage = optional(number, null)
      }), {})
    }), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced CodeCommit Configuration Variables
# ==============================================================================

variable "codecommit_repositories" {
  description = "Map of CodeCommit repositories to create"
  type = map(object({
    repository_name = string
    description = optional(string, null)
    default_branch = optional(string, null)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "codecommit_triggers" {
  description = "Map of CodeCommit triggers to create"
  type = map(object({
    repository_name = string
    triggers = list(object({
      name = string
      destination_arn = string
      custom_data = optional(string, null)
      branches = optional(list(string), [])
      events = list(string)
    }))
  }))
  default = {}
}

variable "codecommit_approval_rule_templates" {
  description = "Map of CodeCommit approval rule templates to create"
  type = map(object({
    name = string
    description = optional(string, null)
    content = string
  }))
  default = {}
}

variable "codecommit_approval_rule_template_associations" {
  description = "Map of CodeCommit approval rule template associations to create"
  type = map(object({
    approval_rule_template_name = string
    repository_name = string
  }))
  default = {}
}

# ==============================================================================
# Enhanced CodeStar Configuration Variables
# ==============================================================================

variable "codestar_connections" {
  description = "Map of CodeStar connections to create"
  type = map(object({
    name = string
    provider_type = string
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "codestar_notifications" {
  description = "Map of CodeStar notifications to create"
  type = map(object({
    detail_type = string
    event_type_ids = list(string)
    name = string
    resource = string
    targets = list(object({
      address = string
      type = optional(string, null)
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced CloudFormation Configuration Variables
# ==============================================================================

variable "cloudformation_stacks" {
  description = "Map of CloudFormation stacks to create"
  type = map(object({
    name = string
    template_body = optional(string, null)
    template_url = optional(string, null)
    parameters = optional(map(string), {})
    capabilities = optional(list(string), [])
    disable_rollback = optional(bool, null)
    notification_arns = optional(list(string), [])
    on_failure = optional(string, null)
    policy_body = optional(string, null)
    policy_url = optional(string, null)
    tags = optional(map(string), {})
    timeout_in_minutes = optional(number, null)
    iam_role_arn = optional(string, null)
    termination_protection = optional(bool, null)
    stack_policy_body = optional(string, null)
    stack_policy_url = optional(string, null)
  }))
  default = {}
}

variable "cloudformation_stack_sets" {
  description = "Map of CloudFormation stack sets to create"
  type = map(object({
    name = string
    template_body = optional(string, null)
    template_url = optional(string, null)
    parameters = optional(map(string), {})
    capabilities = optional(list(string), [])
    description = optional(string, null)
    execution_role_name = optional(string, null)
    administration_role_arn = optional(string, null)
    permission_model = string
    auto_deployment = optional(object({
      enabled = optional(bool, null)
      retain_stacks_on_account_removal = optional(bool, null)
    }), {})
    call_as = optional(string, null)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "cloudformation_stack_set_instances" {
  description = "Map of CloudFormation stack set instances to create"
  type = map(object({
    stack_set_name = string
    account_id = optional(string, null)
    region = optional(string, null)
    deployment_targets = optional(object({
      organizational_unit_ids = optional(list(string), [])
    }), {})
    parameter_overrides = optional(map(string), {})
    operation_preferences = optional(object({
      max_concurrent_count = optional(number, null)
      max_concurrent_percentage = optional(number, null)
      failure_tolerance_count = optional(number, null)
      failure_tolerance_percentage = optional(number, null)
      region_concurrency_type = optional(string, null)
      region_order = optional(list(string), [])
    }), {})
    call_as = optional(string, null)
  }))
  default = {}
}

# ==============================================================================
# Enhanced S3 Configuration Variables
# ==============================================================================

variable "s3_buckets" {
  description = "Map of S3 buckets to create"
  type = map(object({
    name = string
    force_destroy = optional(bool, false)
    acl = optional(string, null)
    versioning = optional(object({
      enabled = optional(bool, false)
      mfa_delete = optional(bool, false)
    }), {})
    server_side_encryption_configuration = optional(object({
      rule = object({
        apply_server_side_encryption_by_default = object({
          sse_algorithm = string
          kms_master_key_id = optional(string, null)
        })
        bucket_key_enabled = optional(bool, null)
      })
    }), {})
    lifecycle_rule = optional(list(object({
      id = optional(string, null)
      prefix = optional(string, null)
      tags = optional(map(string), {})
      enabled = optional(bool, true)
      abort_incomplete_multipart_upload = optional(object({
        days_after_initiation = number
      }), {})
      expiration = optional(object({
        date = optional(string, null)
        days = optional(number, null)
        expired_object_delete_marker = optional(bool, null)
      }), {})
      noncurrent_version_expiration = optional(object({
        noncurrent_days = number
        newer_noncurrent_versions = optional(number, null)
      }), {})
      noncurrent_version_transition = optional(list(object({
        noncurrent_days = number
        storage_class = string
        newer_noncurrent_versions = optional(number, null)
      })), [])
      transition = optional(list(object({
        date = optional(string, null)
        days = optional(number, null)
        storage_class = string
      })), [])
      object_size_greater_than = optional(number, null)
      object_size_less_than = optional(number, null)
    })), [])
    cors_rule = optional(list(object({
      allowed_headers = optional(list(string), [])
      allowed_methods = list(string)
      allowed_origins = list(string)
      expose_headers = optional(list(string), [])
      max_age_seconds = optional(number, null)
    })), [])
    website = optional(object({
      index_document = optional(string, null)
      error_document = optional(string, null)
      redirect_all_requests_to = optional(string, null)
      routing_rules = optional(string, null)
    }), {})
    object_ownership = optional(object({
      object_ownership = string
      rule = optional(object({
        object_ownership = string
      }), {})
    }), {})
    block_public_acls = optional(bool, true)
    block_public_policy = optional(bool, true)
    ignore_public_acls = optional(bool, true)
    restrict_public_buckets = optional(bool, true)
    bucket_ownership_controls = optional(object({
      rule = object({
        object_ownership = string
      })
    }), {})
    intelligent_tiering = optional(list(object({
      id = string
      status = optional(string, "Enabled")
      tiering = list(object({
        access_tier = string
        days = number
      }))
    })), [])
    metric_configuration = optional(list(object({
      id = string
      filter = optional(object({
        prefix = optional(string, null)
        tags = optional(map(string), {})
      }), {})
    })), [])
    inventory = optional(list(object({
      name = string
      enabled = optional(bool, true)
      included_object_versions = optional(string, "Current")
      schedule = object({
        frequency = string
      })
      destination = object({
        bucket = object({
          format = string
          bucket_arn = string
          account_id = optional(string, null)
          prefix = optional(string, null)
          encryption = optional(object({
            sse_kms = optional(object({
              key_id = string
            }), {})
            sse_s3 = optional(object({}), {})
          }), {})
        })
      })
      optional_fields = optional(list(string), [])
    })), [])
    object_lock_configuration = optional(object({
      object_lock_enabled = optional(string, "Enabled")
      rule = optional(object({
        default_retention = object({
          mode = string
          days = optional(number, null)
          years = optional(number, null)
        })
      }), {})
    }), {})
    replication_configuration = optional(object({
      role = string
      rules = list(object({
        id = optional(string, null)
        status = optional(string, "Enabled")
        priority = optional(number, null)
        delete_marker_replication = optional(object({
          status = string
        }), {})
        destination = object({
          bucket = string
          storage_class = optional(string, null)
          replica_kms_key_id = optional(string, null)
          account_id = optional(string, null)
          access_control_translation = optional(object({
            owner = string
          }), {})
          replication_time = optional(object({
            status = string
            minutes = optional(number, null)
          }), {})
          metrics = optional(object({
            status = string
            minutes = optional(number, null)
          }), {})
        })
        source_selection_criteria = optional(object({
          sse_kms_encrypted_objects = optional(object({
            status = string
          }), {})
        }), {})
        filter = optional(object({
          prefix = optional(string, null)
          tags = optional(map(string), {})
        }), {})
      }))
    }), {})
    request_payer = optional(string, null)
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced IAM Configuration Variables
# ==============================================================================

variable "iam_roles" {
  description = "Map of IAM roles to create"
  type = map(object({
    name = string
    assume_role_policy = string
    description = optional(string, null)
    force_detach_policies = optional(bool, false)
    max_session_duration = optional(number, 3600)
    path = optional(string, "/")
    permissions_boundary = optional(string, null)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "iam_policies" {
  description = "Map of IAM policies to create"
  type = map(object({
    name = string
    description = optional(string, null)
    path = optional(string, "/")
    policy = string
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "iam_role_policy_attachments" {
  description = "Map of IAM role policy attachments to create"
  type = map(object({
    role = string
    policy_arn = string
  }))
  default = {}
}

variable "iam_role_policies" {
  description = "Map of IAM role policies to create"
  type = map(object({
    name = string
    role = string
    policy = string
  }))
  default = {}
}

# ==============================================================================
# Enhanced CloudWatch Configuration Variables
# ==============================================================================

variable "cloudwatch_log_groups" {
  description = "Map of CloudWatch log groups to create"
  type = map(object({
    name = string
    retention_in_days = optional(number, 14)
    kms_key_id = optional(string, null)
    skip_destroy = optional(bool, false)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "cloudwatch_alarms" {
  description = "Map of CloudWatch alarms to create"
  type = map(object({
    name = string
    comparison_operator = string
    evaluation_periods = number
    metric_name = string
    namespace = string
    period = number
    statistic = string
    threshold = number
    description = optional(string, null)
    actions_enabled = optional(bool, true)
    alarm_actions = optional(list(string), [])
    insufficient_data_actions = optional(list(string), [])
    ok_actions = optional(list(string), [])
    dimensions = optional(map(string), {})
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced SNS Configuration Variables
# ==============================================================================

variable "sns_topics" {
  description = "Map of SNS topics to create"
  type = map(object({
    name = string
    display_name = optional(string, null)
    policy = optional(string, null)
    delivery_policy = optional(string, null)
    kms_master_key_id = optional(string, null)
    fifo_topic = optional(bool, false)
    content_based_deduplication = optional(bool, false)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "sns_topic_subscriptions" {
  description = "Map of SNS topic subscriptions to create"
  type = map(object({
    topic_arn = string
    protocol = string
    endpoint = string
    endpoint_auto_confirms = optional(bool, null)
    confirmation_timeout_in_minutes = optional(number, null)
    delivery_policy = optional(string, null)
    filter_policy = optional(string, null)
    filter_policy_scope = optional(string, null)
    raw_message_delivery = optional(bool, null)
    redrive_policy = optional(string, null)
    subscription_role_arn = optional(string, null)
  }))
  default = {}
}

# ==============================================================================
# Enhanced EventBridge Configuration Variables
# ==============================================================================

variable "eventbridge_buses" {
  description = "Map of EventBridge event buses to create"
  type = map(object({
    name = string
    event_source_name = optional(string, null)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "eventbridge_rules" {
  description = "Map of EventBridge rules to create"
  type = map(object({
    name = string
    description = optional(string, null)
    event_bus_name = optional(string, "default")
    event_pattern = optional(string, null)
    schedule_expression = optional(string, null)
    role_arn = optional(string, null)
    is_enabled = optional(bool, true)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "eventbridge_targets" {
  description = "Map of EventBridge targets to create"
  type = map(object({
    rule = string
    event_bus_name = optional(string, "default")
    target_id = string
    arn = string
    role_arn = optional(string, null)
    input = optional(string, null)
    input_path = optional(string, null)
    input_transformer = optional(object({
      input_paths = optional(map(string), {})
      input_template = string
    }), {})
    run_command_targets = optional(list(object({
      key = string
      values = list(string)
    })), [])
    ecs_target = optional(object({
      task_count = optional(number, null)
      task_definition_arn = string
      launch_type = optional(string, null)
      network_configuration = optional(object({
        subnets = list(string)
        security_groups = optional(list(string), [])
        assign_public_ip = optional(bool, null)
      }), {})
      platform_version = optional(string, null)
      group = optional(string, null)
    }), {})
    batch_target = optional(object({
      job_definition = string
      job_name = string
      array_size = optional(number, null)
      job_attempts = optional(number, null)
    }), {})
    kinesis_target = optional(object({
      partition_key_path = optional(string, null)
    }), {})
    sqs_target = optional(object({
      message_group_id = optional(string, null)
    }), {})
    http_target = optional(object({
      path_parameter_values = optional(list(string), [])
      header_parameters = optional(map(string), {})
      query_string_parameters = optional(map(string), {})
    }), {})
    redshift_target = optional(object({
      database = string
      db_user = optional(string, null)
      secrets_manager_arn = optional(string, null)
      sql = optional(string, null)
      statement_name = optional(string, null)
      with_event = optional(bool, null)
    }), {})
    sagemaker_pipeline_target = optional(object({
      pipeline_parameter_list = optional(list(object({
        name = string
        value = string
      })), [])
    }), {})
    step_functions_target = optional(object({
      input = optional(string, null)
      input_path = optional(string, null)
    }), {})
    dead_letter_config = optional(object({
      arn = optional(string, null)
    }), {})
    retry_policy = optional(object({
      maximum_event_age_in_seconds = optional(number, null)
      maximum_retry_attempts = optional(number, null)
    }), {})
  }))
  default = {}
} 