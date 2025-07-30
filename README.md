# AWS CodePipeline CI/CD Terraform Module

A comprehensive Terraform module for creating AWS CI/CD pipelines using CodeCommit, CodeBuild, CodeDeploy, CodePipeline, S3, and CloudFormation.

## Features

- **Source Control**: AWS CodeCommit repository for source code management
- **Build Automation**: AWS CodeBuild for automated builds and testing
- **Deployment**: AWS CodeDeploy for application deployment
- **Pipeline Orchestration**: AWS CodePipeline for end-to-end CI/CD workflow
- **Artifact Storage**: S3 bucket with encryption and lifecycle policies
- **Infrastructure as Code**: CloudFormation integration for infrastructure deployment
- **Monitoring**: CloudWatch alarms and logging
- **Notifications**: SNS topics for pipeline event notifications
- **Security**: IAM roles with least privilege access
- **Compliance**: Resource tagging and audit trails

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   CodeCommit    │───▶│   CodeBuild     │───▶│   CodeDeploy    │
│   Repository    │    │   Project       │    │   Application   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   CodePipeline  │    │   S3 Artifacts  │    │ CloudFormation  │
│   Orchestration │    │   Bucket        │    │   Stack         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   CloudWatch    │    │   SNS Topics    │    │   EventBridge   │
│   Monitoring    │    │   Notifications │    │   Triggers      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Usage

### Basic Example

```hcl
module "cicd_pipeline" {
  source = "./tfm-aws-codepipeline"

  project_name                = "my-web-app"
  environment                 = "prod"
  artifacts_bucket_name       = "my-web-app-artifacts-123456789012"
  codecommit_repository_name  = "my-web-app-repo"

  common_tags = {
    Environment = "prod"
    Project     = "my-web-app"
    Owner       = "devops-team"
  }
}
```

### Advanced Example with CloudFormation

```hcl
module "cicd_pipeline" {
  source = "./tfm-aws-codepipeline"

  project_name                = "my-web-app"
  environment                 = "prod"
  artifacts_bucket_name       = "my-web-app-artifacts-123456789012"
  codecommit_repository_name  = "my-web-app-repo"

  # Build configuration
  build_timeout = 120
  build_compute_type = "BUILD_GENERAL1_MEDIUM"
  build_privileged_mode = true
  
  build_environment_variables = [
    {
      key   = "NODE_ENV"
      value = "production"
    },
    {
      key   = "BUILD_VERSION"
      value = "1.0.0"
    }
  ]

  # Deployment configuration
  deploy_enabled = true
  deploy_compute_platform = "Server"
  
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
        value = "my-web-app"
      }
    ]
  ]

  # CloudFormation configuration
  cloudformation_deploy_enabled = true
  create_cloudformation_stack = true
  cloudformation_template_body = file("${path.module}/templates/infrastructure.yaml")
  cloudformation_capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]

  # Monitoring and notifications
  enable_notifications = true
  notification_emails = ["devops@company.com", "alerts@company.com"]
  enable_pipeline_monitoring = true
  enable_pipeline_triggers = true

  # Logging and retention
  log_retention_days = 30
  artifact_retention_days = 90

  common_tags = {
    Environment = "prod"
    Project     = "my-web-app"
    Owner       = "devops-team"
    CostCenter  = "engineering"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.0 |

## Inputs

### Required Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Name of the project, used for resource naming | `string` | n/a | yes |
| environment | Environment name (e.g., dev, staging, prod) | `string` | n/a | yes |
| artifacts_bucket_name | Name of the S3 bucket for storing pipeline artifacts | `string` | n/a | yes |
| codecommit_repository_name | Name of the CodeCommit repository | `string` | n/a | yes |

### Optional Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| common_tags | Common tags to apply to all resources | `map(string)` | `{}` | no |
| source_branch | Source branch for the pipeline | `string` | `"main"` | no |
| buildspec_file | Path to the buildspec file in the repository | `string` | `"buildspec.yml"` | no |
| build_timeout | Build timeout in minutes | `number` | `60` | no |
| build_compute_type | CodeBuild compute type | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| build_image | CodeBuild image to use | `string` | `"aws/codebuild/amazonlinux2-x86_64-standard:4.0"` | no |
| build_privileged_mode | Enable privileged mode for CodeBuild | `bool` | `false` | no |
| build_environment_variables | Environment variables for CodeBuild | `list(object({key = string, value = string}))` | `[]` | no |
| deploy_enabled | Enable CodeDeploy deployment stage | `bool` | `true` | no |
| deploy_compute_platform | CodeDeploy compute platform | `string` | `"Server"` | no |
| deployment_config_name | CodeDeploy deployment configuration name | `string` | `"CodeDeployDefault.OneAtATime"` | no |
| deploy_ec2_tag_sets | EC2 tag sets for CodeDeploy deployment group | `list(list(object({key = string, type = string, value = string})))` | `[]` | no |
| auto_rollback_enabled | Enable auto rollback for CodeDeploy | `bool` | `true` | no |
| auto_rollback_events | Events that trigger auto rollback | `list(string)` | `["DEPLOYMENT_FAILURE"]` | no |
| alarm_configuration_enabled | Enable alarm configuration for CodeDeploy | `bool` | `false` | no |
| ignore_poll_alarm_failure | Ignore poll alarm failure for CodeDeploy | `bool` | `false` | no |
| alarm_names | CloudWatch alarm names for CodeDeploy | `list(string)` | `[]` | no |
| cloudformation_deploy_enabled | Enable CloudFormation deployment stage | `bool` | `false` | no |
| create_cloudformation_stack | Create a new CloudFormation stack | `bool` | `false` | no |
| cloudformation_stack_name | Name of existing CloudFormation stack to update | `string` | `""` | no |
| cloudformation_template_body | CloudFormation template body | `string` | `""` | no |
| cloudformation_template_path | Path to CloudFormation template in source artifacts | `string` | `"template.yaml"` | no |
| cloudformation_capabilities | CloudFormation capabilities | `list(string)` | `["CAPABILITY_IAM"]` | no |
| cloudformation_parameters | CloudFormation parameters | `list(object({key = string, value = string}))` | `[]` | no |
| artifact_retention_days | Number of days to retain artifacts in S3 | `number` | `30` | no |
| log_retention_days | Number of days to retain CloudWatch logs | `number` | `14` | no |
| enable_pipeline_triggers | Enable automatic pipeline triggers on CodeCommit changes | `bool` | `true` | no |
| enable_notifications | Enable SNS notifications for pipeline events | `bool` | `false` | no |
| notification_emails | Email addresses for pipeline notifications | `list(string)` | `[]` | no |
| enable_pipeline_monitoring | Enable CloudWatch alarms for pipeline monitoring | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| artifacts_bucket_name | Name of the S3 bucket used for artifacts |
| artifacts_bucket_arn | ARN of the S3 bucket used for artifacts |
| codecommit_repository_name | Name of the CodeCommit repository |
| codecommit_clone_url_http | HTTP clone URL for the CodeCommit repository |
| codecommit_clone_url_ssh | SSH clone URL for the CodeCommit repository |
| codebuild_project_name | Name of the CodeBuild project |
| codedeploy_app_name | Name of the CodeDeploy application |
| codepipeline_name | Name of the CodePipeline |
| codepipeline_arn | ARN of the CodePipeline |
| cloudformation_stack_name | Name of the CloudFormation stack |
| codepipeline_role_arn | ARN of the CodePipeline IAM role |
| codebuild_role_arn | ARN of the CodeBuild IAM role |
| codedeploy_role_arn | ARN of the CodeDeploy IAM role |
| codepipeline_log_group_name | Name of the CodePipeline CloudWatch log group |
| codebuild_log_group_name | Name of the CodeBuild CloudWatch log group |
| pipeline_trigger_rule_name | Name of the EventBridge rule for pipeline triggers |
| pipeline_notifications_topic_arn | ARN of the SNS topic for pipeline notifications |
| pipeline_failures_alarm_name | Name of the CloudWatch alarm for pipeline failures |
| build_failures_alarm_name | Name of the CloudWatch alarm for build failures |
| pipeline_url | URL to view the CodePipeline in the AWS Console |
| codecommit_url | URL to view the CodeCommit repository in the AWS Console |
| codebuild_url | URL to view the CodeBuild project in the AWS Console |
| codedeploy_url | URL to view the CodeDeploy application in the AWS Console |
| module_summary | Summary of all resources created by this module |

## Examples

### Basic Pipeline

See the `examples/basic` directory for a simple pipeline setup.

### Advanced Pipeline with CloudFormation

See the `examples/advanced` directory for a comprehensive setup with CloudFormation deployment.

### Multi-Environment Setup

See the `examples/multi-environment` directory for managing multiple environments.

## Buildspec Examples

### Node.js Application

```yaml
version: 0.2

phases:
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws --version
      - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
      - REPOSITORY_URI=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME
      - COMMIT_HASH=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c 1-7)
      - IMAGE_TAG=${COMMIT_HASH:=latest}
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...
      - docker build -t $IMAGE_REPO_NAME:$IMAGE_TAG .
      - docker tag $IMAGE_REPO_NAME:$IMAGE_TAG $REPOSITORY_URI:$IMAGE_TAG
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker image...
      - docker push $REPOSITORY_URI:$IMAGE_TAG
      - echo Writing image definitions file...
      - printf '[{"name":"container_name","imageUri":"%s"}]' $REPOSITORY_URI:$IMAGE_TAG > imagedefinitions.json
artifacts:
  files:
    - imagedefinitions.json
```

### Python Application

```yaml
version: 0.2

phases:
  install:
    runtime-versions:
      python: 3.9
    commands:
      - pip install --upgrade pip
      - pip install -r requirements.txt
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
      - REPOSITORY_URI=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME
      - COMMIT_HASH=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c 1-7)
      - IMAGE_TAG=${COMMIT_HASH:=latest}
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...
      - docker build -t $IMAGE_REPO_NAME:$IMAGE_TAG .
      - docker tag $IMAGE_REPO_NAME:$IMAGE_TAG $REPOSITORY_URI:$IMAGE_TAG
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker image...
      - docker push $REPOSITORY_URI:$IMAGE_TAG
      - echo Writing image definitions file...
      - printf '[{"name":"container_name","imageUri":"%s"}]' $REPOSITORY_URI:$IMAGE_TAG > imagedefinitions.json
artifacts:
  files:
    - imagedefinitions.json
```

## Security Considerations

- All IAM roles follow the principle of least privilege
- S3 buckets are encrypted and have public access blocked
- CloudWatch logs are encrypted and have retention policies
- All resources are tagged for cost tracking and compliance
- Pipeline artifacts are automatically cleaned up based on retention policies

## Best Practices

1. **Use meaningful project names**: Choose descriptive names that reflect the application or service
2. **Tag all resources**: Apply consistent tagging for cost tracking and resource management
3. **Enable monitoring**: Use CloudWatch alarms to monitor pipeline health
4. **Set up notifications**: Configure SNS notifications for important pipeline events
5. **Use environment-specific configurations**: Differentiate between dev, staging, and prod environments
6. **Implement proper retention policies**: Set appropriate retention periods for logs and artifacts
7. **Test thoroughly**: Validate your pipeline configuration before deploying to production
8. **Use version control**: Store your Terraform configurations in version control
9. **Document your setup**: Maintain clear documentation of your pipeline configuration
10. **Regular maintenance**: Review and update your pipeline configuration regularly

## Troubleshooting

### Common Issues

1. **IAM Permission Errors**: Ensure your AWS credentials have the necessary permissions
2. **S3 Bucket Name Conflicts**: S3 bucket names must be globally unique
3. **CodeBuild Timeout**: Increase the build timeout for complex builds
4. **CodeDeploy Failures**: Check EC2 instance tags and IAM roles
5. **CloudFormation Errors**: Validate your CloudFormation templates

### Debugging Steps

1. Check CloudWatch logs for detailed error messages
2. Verify IAM roles and policies
3. Test individual pipeline stages
4. Review S3 bucket permissions
5. Check CodeCommit repository access

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This module is licensed under the MIT License. See the LICENSE file for details.

## Support

For support and questions, please open an issue in the GitHub repository.