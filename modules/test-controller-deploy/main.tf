locals {
  name = "test-controller"
  tags = var.tags
}

################################
#### DEPLOY ####################
################################

# Get the current region
data "alicloud_region" "current" {}

# Alibaba Cloud Resource Access Management (RAM) User
data "alicloud_ram_account_alias" "current" {}

# OSS Bucket
resource "alicloud_oss_bucket" "pipeline" {
  bucket = "${data.alicloud_ram_account_alias.current.alias}-${data.alicloud_region.current.name}-${local.name}-codepipeline"
  force_destroy = true
  tags = local.tags
}

# OSS Bucket Encryption
resource "alicloud_oss_bucket_encryption" "pipeline" {
  bucket = alicloud_oss_bucket.pipeline.bucket
  sse_algorithm = "AES256"
}

# RAM Role for CodePipeline
resource "alicloud_ram_role" "pipeline" {
  name = "${local.name}-pipeline-role"
  document = <<EOF
{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "*"
    }
  ],
  "Version": "1"
}
EOF
  tags = local.tags
}

# RAM Policy for CodePipeline
resource "alicloud_ram_policy" "pipeline" {
  name = "${local.name}-pipeline-policy"
  description = "Policy for CodePipeline"
  document = <<EOF
{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "oss:GetObject",
        "oss:ListObjects",
        "oss:PutObject"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecs:Describe*",
        "ecs:Create*",
        "ecs:Start*",
        "ecs:Stop*",
        "ecs:Delete*",
        "ecs:Update*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ram:PassRole",
      "Resource": "*"
    }
  ],
  "Version": "1"
}
EOF
}

resource "alicloud_ram_role_policy_attachment" "pipeline" {
  role_name = alicloud_ram_role.pipeline.name
  policy_name = alicloud_ram_policy.pipeline.name
  policy_type = "Custom"
}

# RAM Role for CodeBuild
resource "alicloud_ram_role" "codebuild" {
  name = "${local.name}-codebuild-role"
  document = <<EOF
{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "*"
    }
  ],
  "Version": "1"
}
EOF
  tags = local.tags
}

# RAM Policy for CodeBuild
resource "alicloud_ram_policy" "codebuild" {
  name = "${local.name}-codebuild-policy"
  description = "Policy for CodeBuild"
  document = <<EOF
{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "oss:GetObject",
        "oss:ListObjects",
        "oss:PutObject"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecs:Describe*",
        "ecs:Create*",
        "ecs:Start*",
        "ecs:Stop*",
        "ecs:Delete*",
        "ecs:Update*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ram:PassRole",
      "Resource": "*"
    }
  ],
  "Version": "1"
}
EOF
}

resource "alicloud_ram_role_policy_attachment" "codebuild" {
  role_name = alicloud_ram_role.codebuild.name
  policy_name = alicloud_ram_policy.codebuild.name
  policy_type = "Custom"
}

# Security Group for CodePipeline
resource "alicloud_security_group" "codepipeline" {
  name = "${local.name}-pipeline-sg"
  vpc_id = var.vpc_id
  tags = var.tags
}

resource "alicloud_security_group_rule" "codepipeline_egress" {
  type = "egress"
  ip_protocol = "all"
  nic_type = "internet"
  policy = "accept"
  port_range = "1/65535"
  cidr_ip = "0.0.0.0/0"
  security_group_id = alicloud_security_group.codepipeline.id
}

# CodeBuild Project for Controller Build
resource "alicloud_devops_project" "controller_build" {
  name = "${local.name}-controller-build"
  description = "Codebuild"
  service_role = alicloud_ram_role.codebuild.arn

  vpc_config {
    vpc_id = var.vpc_id
    subnet_ids = var.private_subnets
    security_group_id = alicloud_security_group.codepipeline.id
  }

  environment {
    compute_type = "build"
    image = "registry.cn-hangzhou.aliyuncs.com/acs/codebuild:latest"
    type = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name = "REPOSITORY_URI"
      value = var.test_controller_ecr_repo
    }
    environment_variable {
      name = "SERVICE_NAME"
      value = var.test_controller_ecs_service_name
    }
    environment_variable {
      name = "NODE_BUILD_IMAGE"
      value = var.node_container_build_image
    }
    environment_variable {
      name = "GOLANG_BUILD_IMAGE"
      value = var.golang_container_build_image
    }
    environment_variable {
      name = "APP_BASE_IMAGE"
      value = var.app_container_base_image
    }
  }

  source {
    type = "GIT"
    location = var.github_repo
    buildspec = <<BUILDSPEC
version: 0.2

phases:
  install:
    runtime-versions:
      docker: 18
  pre_build:
    commands:
      - echo Logging in to ACR...
      - aliyun --version
      - $(aliyun ecr get-login --region $ACS_DEFAULT_REGION --no-include-email)
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...
      - |
        docker build \
          --build-arg GIT_DATE=`date "+%Y%m%d"` \
          --build-arg GIT_COMMIT=$CODEBUILD_RESOLVED_SOURCE_VERSION \
          --build-arg NODE_BUILD_IMAGE=$NODE_BUILD_IMAGE \
          --build-arg GOLANG_BUILD_IMAGE=$GOLANG_BUILD_IMAGE \
          --build-arg APP_BASE_IMAGE=$APP_BASE_IMAGE \
          -f Dockerfile.coordinator \
          -t $REPOSITORY_URI:latest .
      - docker tag $REPOSITORY_URI:latest $REPOSITORY_URI:$CODEBUILD_RESOLVED_SOURCE_VERSION
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker images...
      - docker push $REPOSITORY_URI:latest
      - docker push $REPOSITORY_URI:$CODEBUILD_RESOLVED_SOURCE_VERSION
      - echo Writing image definitions file...
      - printf '[{"name":"%s","imageUri":"%s"}]' $SERVICE_NAME $REPOSITORY_URI:$CODEBUILD_RESOLVED_SOURCE_VERSION > imagedefinitions.json

artifacts:
  files:
    - imagedefinitions.json
BUILDSPEC
  }

  tags = local.tags
}

# CodeBuild Project for Agent Build
resource "alicloud_devops_project" "agent_build" {
  name = "${local.name}-agent-build"
  description = "Codebuild"
  service_role = alicloud_ram_role.codebuild.arn

  vpc_config {
    vpc_id = var.vpc_id
    subnet_ids = var.private_subnets
    security_group_id = alicloud_security_group.codepipeline.id
  }

  environment {
    compute_type = "build"
    image = "registry.cn-hangzhou.aliyuncs.com/acs/codebuild:latest"
    type = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name = "GOLANG_BUILD_IMAGE"
      value = var.golang_container_build_image
    }
    environment_variable {
      name = "APP_BASE_IMAGE"
      value = var.app_container_base_image
    }
  }

  source {
    type = "GIT"
    location = var.github_repo
    buildspec = <<BUILDSPEC
version: 0.2

phases:
  install:
    runtime-versions:
      docker: 18
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...
      - |
        docker build \
          --build-arg GIT_DATE=`date "+%Y%m%d"` \
          --build-arg GIT_COMMIT=$CODEBUILD_RESOLVED_SOURCE_VERSION \
          --build-arg GOLANG_BUILD_IMAGE=$GOLANG_BUILD_IMAGE \
          --build-arg APP_BASE_IMAGE=$APP_BASE_IMAGE \
          -f Dockerfile.agent \
          -t agent:latest .
      - docker tag agent:latest agent:$CODEBUILD_RESOLVED_SOURCE_VERSION
      - docker container create --name temp agent:latest
      - docker container cp temp:/app/agent ./agent-latest
      - docker container cp temp:/app/requirements.txt ./requirements.txt
artifacts:
  files:
    - agent-latest
    - requirements.txt
BUILDSPEC
  }

  tags = local.tags
}

# CodeBuild Project for UHS Seed Generator
resource "alicloud_devops_project" "uhs_seed_generator" {
  name = "${local.name}-uhs-seed-generator"
  description = "Codebuild"
  service_role = alicloud_ram_role.codebuild.arn

  vpc_config {
    vpc_id = var.vpc_id
    subnet_ids = var.private_subnets
    security_group_id = alicloud_security_group.codepipeline.id
  }

  environment {
    compute_type = "build"
    image = "registry.cn-hangzhou.aliyuncs.com/acs/codebuild:latest"
    type = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name = "REPOSITORY_URI"
      value = var.uhs_seed_generator_ecr_repo
    }
    environment_variable {
      name = "APP_BASE_IMAGE"
      value = var.app_container_base_image
    }
  }

  source {
    type = "GIT"
    location = var.github_repo
    buildspec = <<BUILDSPEC
version: 0.2

phases:
  install:
    runtime-versions:
      docker: 18
  pre_build:
    commands:
      - echo Logging in to ACR...
      - aliyun --version
      - $(aliyun ecr get-login --region $ACS_DEFAULT_REGION --no-include-email)
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...
      - |
        docker build \
          -f Dockerfile.seeder \
          --build-arg APP_BASE_IMAGE=$APP_BASE_IMAGE \
          -t $REPOSITORY_URI:latest .
      - docker tag $REPOSITORY_URI:latest $REPOSITORY_URI:$CODEBUILD_RESOLVED_SOURCE_VERSION
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker images...
      - docker push $REPOSITORY_URI:latest
      - docker push $REPOSITORY_URI:$CODEBUILD_RESOLVED_SOURCE_VERSION
      - echo Writing image definitions file...
      - printf '[{"name":"%s","imageUri":"%s"}]' $SERVICE_NAME $REPOSITORY_URI:$CODEBUILD_RESOLVED_SOURCE_VERSION > imagedefinitions.json

artifacts:
  files:
    - imagedefinitions.json
BUILDSPEC
  }

  tags = local.tags
}

# CodeBuild Project for Agent Deploy Binary
resource "alicloud_devops_project" "agent_deploy_binary" {
  name = "${local.name}-agent-deploy-binary"
  description = "Codebuild"
  service_role = alicloud_ram_role.codebuild.arn

  vpc_config {
    vpc_id = var.vpc_id
    subnet_ids = var.private_subnets
    security_group_id = alicloud_security_group.codepipeline.id
  }

  environment {
    compute_type = "build"
    image = "registry.cn-hangzhou.aliyuncs.com/acs/codebuild:latest"
    type = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name = "OSS_BUCKET"
      value = var.binaries_oss_bucket
    }
  }

  source {
    type = "GIT"
    location = var.github_repo
    buildspec = <<BUILDSPEC
version: 0.2

phases:
  install:
    runtime-versions:
      docker: 18
  build:
    commands:
      - echo Uploading binary and requirements.txt to OSS...
      - ossutil cp ./agent-latest oss://$OSS_BUCKET/test-controller-agent/
      - ossutil cp ./requirements.txt oss://$OSS_BUCKET/test-controller-agent/
BUILDSPEC
  }

  tags = local.tags
}

# CodePipeline
resource "alicloud_devops_pipeline" "this" {
  name = "${local.name}-pipeline"
  role_arn = alicloud_ram_role.pipeline.arn

  artifact_store {
    location = alicloud_oss_bucket.pipeline.bucket
    type = "OSS"
  }

  stage {
    name = "Source"

    action {
      name = "Source"
      category = "Source"
      owner = "ThirdParty"
      provider = "GitHub"
      version = "1"
      output_artifacts = ["source"]

      configuration = {
        OAuthToken = var.github_access_token
        Owner = var.github_repo_owner
        Repo = var.github_repo
        Branch = var.github_repo_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name = "Controller"
      category = "Build"
      owner = "AlibabaCloud"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = ["source"]
      output_artifacts = ["controller_build"]
      run_order = 1

      configuration = {
        ProjectName = alicloud_devops_project.controller_build.name
      }
    }

    action {
      name = "Agent"
      category = "Build"
      owner = "AlibabaCloud"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = ["source"]
      output_artifacts = ["agent_build"]
      run_order = 1

      configuration = {
        ProjectName = alicloud_devops_project.agent_build.name
      }
    }

    action {
      name = "UHS_Seed_Generator"
      category = "Build"
      owner = "AlibabaCloud"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = ["source"]
      output_artifacts = ["uhs_seed_generator"]
      run_order = 1

      configuration = {
        ProjectName = alicloud_devops_project.uhs_seed_generator.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name = "Controller"
      category = "Deploy"
      owner = "AlibabaCloud"
      provider = "ECS"
      version = "1"
      input_artifacts = ["controller_build"]
      run_order = 1

      configuration = {
        ClusterName = "acs:ecs:${data.alicloud_region.current.name}:${data.alicloud_ram_account_alias.current.alias}:cluster/${var.cluster_name}"
        ServiceName = var.test_controller_ecs_service_name
      }
    }

    action {
      name = "Agent_Binary_to_OSS"
      category = "Build"
      owner = "AlibabaCloud"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = ["agent_build"]
      run_order = 1

      configuration = {
        ProjectName = alicloud_devops_project.agent_deploy_binary.name
      }
    }
  }

  tags = local.tags
}
